package renderer

import "core:crypto"
import "core:fmt"
import "core:log"
import glm "core:math/linalg/glsl"
import "core:mem"
import "core:path/filepath"
import "core:strings"

import "../vendor/assimp"

BoneInfo :: struct {
	id:     u32,
	offset: glm.mat4,
}

Model :: struct {
	meshes:        [dynamic]^Mesh,
	materials:     [dynamic]MaterialHandle,
	bone_info_map: map[string]BoneInfo,
	bone_count:    u32,
}

@(export)
model_new :: proc(file_path: string) -> ^Model {
	log.infof("Loading model: {}", file_path)

	import_flags := get_import_flags_by_extension(file_path)

	// assimp.set_import_property_integer("AI_CONFIG_IMPORT_FBX_PRESERVE_PIVOTS", 0)
	scene := assimp.import_file(file_path, u32(import_flags))

	defer {
		// assimp.release_import(scene)
		assimp.free_scene(scene)
		log.info("Model loaded, unload model's scene completed!")
	}

	if scene == nil ||
	   scene.mFlags & u32(assimp.SceneFlags.INCOMPLETE) != 0 ||
	   scene.mRootNode == nil {
		log.error("Failed to load model: ", file_path)
		return nil
	}

	base_path := filepath.dir(file_path)

	model := new(Model)
	extract_materials(model, scene, base_path)
	process_root_node(scene.mRootNode, scene, model)

	return model
}

process_root_node :: proc(root: ^assimp.Node, scene: ^assimp.Scene, model: ^Model) {
	stack: [dynamic]^assimp.Node = make([dynamic]^assimp.Node)
	defer delete(stack)
	append(&stack, root)

	for len(stack) > 0 {
		node := stack[len(stack) - 1]
		pop(&stack)

		for i in 0 ..< node.mNumMeshes {
			mesh_idx := node.mMeshes[i]
			mesh := scene.mMeshes[mesh_idx]
			extract_mesh(model, scene, mesh)
		}

		for i in 0 ..< node.mNumChildren {
			append(&stack, node.mChildren[i])
		}
	}
}

extract_mesh :: proc(model: ^Model, scene: ^assimp.Scene, mesh: ^assimp.Mesh) {
	vertices: []Vertex = make([]Vertex, mesh.mNumVertices)
	defer delete(vertices)
	for i in 0 ..< mesh.mNumVertices {
		vertices[i].position = mesh.mVertices[i].xyz

		if mesh.mColors[0] != nil {
			vertices[i].color = mesh.mColors[0][i].rgb
		}

		if mesh.mNormals != nil {
			vertices[i].normal = mesh.mNormals[i].xyz
		}

		if mesh.mTextureCoords[0] != nil {
			vertices[i].tex_coords = mesh.mTextureCoords[0][i].xy
		} else {
			vertices[i].tex_coords = {0.0, 0.0}
		}

		if mesh.mTangents != nil {
			vertices[i].tangent = mesh.mTangents[i].xyz
		}

		if mesh.mBitangents != nil {
			vertices[i].bitanget = mesh.mBitangents[i].xyz
		}
	}

	// Get indices
	index_count: u32 = 0
	for i in 0 ..< mesh.mNumFaces {
		index_count += mesh.mFaces[i].mNumIndices
	}
	indices: []u32 = make([]u32, index_count)
	defer delete(indices)

	idx: u32 = 0
	for i in 0 ..< mesh.mNumFaces {
		face := mesh.mFaces[i]
		for j in 0 ..< face.mNumIndices {
			indices[idx] = face.mIndices[j]
			idx += 1
		}
	}

	extract_bones(model, mesh, scene, vertices)

	mat_name: assimp.String
	if assimp.get_material_string(
		   scene.mMaterials[mesh.mMaterialIndex],
		   "?mat.name",
		   0,
		   0,
		   &mat_name,
	   ) !=
	   assimp.Return.SUCCESS {
		log.error("Failed to get material name")
	}


	name := string(mat_name.data[:mat_name.length])
	append(&model.meshes, mesh_new(vertices, indices, MaterialHandle(strings.clone(name))))
}

extract_bones :: proc(
	model: ^Model,
	mesh: ^assimp.Mesh,
	scene: ^assimp.Scene,
	vertices: []Vertex,
) {
	if mesh.mNumBones == 0 {
		return
	}

	log.debugf("Extracting bones for mesh: {}", mesh.mName.data[:mesh.mName.length])

	for bone_idx in 0 ..< mesh.mNumBones {
		bone_id: i32 = -1
		bone_name := string(mesh.mBones[bone_idx].mName.data[:mesh.mBones[bone_idx].mName.length])
		if _, ok := model.bone_info_map[bone_name]; !ok {
			bone_info := BoneInfo{}
			bone_info.id = model.bone_count
			bone_info.offset = transmute(glm.mat4)mesh.mBones[bone_idx].mOffsetMatrix
			model.bone_info_map[bone_name] = bone_info
			bone_id = i32(model.bone_count)
			model.bone_count += 1
		} else {
			bone_id = i32(model.bone_info_map[bone_name].id)
		}
		assert(bone_id != -1)

		num_weights := mesh.mBones[bone_idx].mNumWeights
		weights := mesh.mBones[bone_idx].mWeights

		if weights == nil {
			log.errorf("No weights for bone: {}", bone_name)
			continue
		}

		for weight_idx in 0 ..< num_weights {
			vertex_id := weights[weight_idx].mVertexId
			weight := weights[weight_idx].mWeight
			assert(vertex_id < u32(len(vertices)))

			for k in 0 ..< MAX_BONE_INFLUENCES {
				if vertices[vertex_id].bones_ids[k] < 0.0 {
					vertices[vertex_id].bones_ids[k] = bone_id
					vertices[vertex_id].weights[k] = weight
					break
				}
			}
		}

	}
}

extract_materials :: proc(model: ^Model, scene: ^assimp.Scene, base_path: string) {
	for i in 0 ..< scene.mNumMaterials {
		mat: ^assimp.Material = scene.mMaterials[i]

		mat_name: assimp.String
		if assimp.get_material_string(mat, "?mat.name", 0, 0, &mat_name) != assimp.Return.SUCCESS {
			log.error("Failed to get material name")
			continue
		}

		max: u32
		shininess: f64
		if assimp.get_material_floatArray(mat, "$mat.shininess", 0, 0, &shininess, &max) !=
		   assimp.Return.SUCCESS {
			log.error("Failed to get material name")
			continue
		}

		if max > 1 {
			log.error("More than one shininess value")
			continue
		}

		diffuse, specular, height, ambient: TextureHandle = "", "", "", ""
		// Get textures, NOTE: more than one texture per type is not supported
		if assimp.get_material_textureCount(mat, assimp.TextureType.DIFFUSE) > 0 {
			relative_path: assimp.String
			mapping: assimp.TextureMapping
			uvindex: u32
			blend: f64
			op: assimp.TextureOp
			mapmode: assimp.TextureMapMode
			if assimp.get_material_texture(
				   mat,
				   assimp.TextureType.DIFFUSE,
				   0,
				   &relative_path,
				   &mapping,
				   &uvindex,
				   &blend,
				   &op,
				   &mapmode,
			   ) !=
			   assimp.Return.SUCCESS {
				log.error("Failed to get material texture")
				continue
			}

			texture_path := filepath.join(
				{base_path, transmute(string)relative_path.data[:relative_path.length]},
			)

			diffuse = resource_manager_add(texture_path, TextureType.Diffuse)
		}
		if assimp.get_material_textureCount(mat, assimp.TextureType.SPECULAR) > 0 {
			relative_path: assimp.String
			mapping: assimp.TextureMapping
			uvindex: u32
			blend: f64
			op: assimp.TextureOp
			mapmode: assimp.TextureMapMode
			if assimp.get_material_texture(
				   mat,
				   assimp.TextureType.SPECULAR,
				   0,
				   &relative_path,
				   &mapping,
				   &uvindex,
				   &blend,
				   &op,
				   &mapmode,
			   ) !=
			   assimp.Return.SUCCESS {
				log.error("Failed to get material texture")
				continue
			}

			texture_path := filepath.join(
				{base_path, transmute(string)relative_path.data[:relative_path.length]},
			)

			specular = resource_manager_add(texture_path, TextureType.Specular)
		}
		if assimp.get_material_textureCount(mat, assimp.TextureType.HEIGHT) > 0 {
			relative_path: assimp.String
			mapping: assimp.TextureMapping
			uvindex: u32
			blend: f64
			op: assimp.TextureOp
			mapmode: assimp.TextureMapMode
			if assimp.get_material_texture(
				   mat,
				   assimp.TextureType.HEIGHT,
				   0,
				   &relative_path,
				   &mapping,
				   &uvindex,
				   &blend,
				   &op,
				   &mapmode,
			   ) !=
			   assimp.Return.SUCCESS {
				log.error("Failed to get material texture")
				continue
			}

			texture_path := filepath.join(
				{base_path, transmute(string)relative_path.data[:relative_path.length]},
			)

			height = resource_manager_add(texture_path, TextureType.Height)
		}
		if assimp.get_material_textureCount(mat, assimp.TextureType.AMBIENT) > 0 {
			relative_path: assimp.String
			mapping: assimp.TextureMapping
			uvindex: u32
			blend: f64
			op: assimp.TextureOp
			mapmode: assimp.TextureMapMode
			if assimp.get_material_texture(
				   mat,
				   assimp.TextureType.AMBIENT,
				   0,
				   &relative_path,
				   &mapping,
				   &uvindex,
				   &blend,
				   &op,
				   &mapmode,
			   ) !=
			   assimp.Return.SUCCESS {
				log.error("Failed to get material texture")
				continue
			}

			texture_path := filepath.join(
				{base_path, transmute(string)relative_path.data[:relative_path.length]},
			)

			ambient = resource_manager_add(texture_path, TextureType.Ambient)
		}

		if shininess == 0.0 && diffuse == "" && specular == "" && height == "" && ambient == "" {
			continue
		}

		append(
			&model.materials,
			resource_manager_add(
				strings.clone(transmute(string)mat_name.data[:mat_name.length]),
				diffuse,
				specular,
				height,
				ambient,
				shininess,
			),
		)
	}
}

@(export)
model_free :: proc(model: ^Model) {
	for &mesh in model.meshes {
		mesh_free(mesh)
	}

	for &material in model.materials {
		resource_manager_delete(material)
	}

	delete_map(model.bone_info_map)
	delete(model.meshes)
	delete(model.materials)
	free(model)
}

@(export)
model_draw :: proc(model: ^Model, shader: ShaderProgram) {
	for &mesh in model.meshes {
		mesh_draw_with_material(mesh, shader)
	}
}


@(private)
get_import_flags_by_extension :: proc(file_path: string) -> assimp.PostProcessSteps {
	flags: assimp.PostProcessSteps =
		assimp.PostProcessSteps.Triangulate |
		assimp.PostProcessSteps.JoinIdenticalVertices |
		assimp.PostProcessSteps.GenNormals |
		assimp.PostProcessSteps.CalcTangentSpace |
		assimp.PostProcessSteps.ValidateDataStructure |
		assimp.PostProcessSteps.LimitBoneWeights

	ext := filepath.ext(file_path)
	switch ext {
	case ".obj":
		flags |= assimp.PostProcessSteps.FlipUVs
	case ".blend", ".dae", ".3ds", ".ase", ".ifc", ".xgl", ".zgl":
	// flags |= assimp.PostProcessSteps.FlipUVs
	case ".fbx":
	// flags |= assimp.PostProcessSteps.MakeLeftHanded
	case ".gltf":
	// flags |= assimp.PostProcessSteps.FlipWindingOrder
	}

	return flags
}
