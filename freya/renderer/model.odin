package renderer

import "core:crypto"
import "core:fmt"
import "core:log"
import "core:path/filepath"
import "core:strings"

import "../vendor/assimp"

Model :: struct {
	meshes:    [dynamic]^Mesh,
	materials: [dynamic]MaterialHandle,
}

@(export)
model_new :: proc(file_path: string) -> ^Model {
	log.infof("Loading model: {}", file_path)

	scene := assimp.import_file(
		file_path,
		u32(
			assimp.PostProcessSteps.Triangulate |
			assimp.PostProcessSteps.FlipUVs |
			assimp.PostProcessSteps.GenSmoothNormals |
			assimp.PostProcessSteps.CalcTangentSpace,
		),
	)
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

		// log.debug("Processing node: ", transmute(string)node.mName.data[:node.mName.length])

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
	for i in 0 ..< mesh.mNumVertices {
		vertices[i].position = mesh.mVertices[i].xyz

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

	idx: u32 = 0
	for i in 0 ..< mesh.mNumFaces {
		face := mesh.mFaces[i]
		for j in 0 ..< face.mNumIndices {
			indices[idx] = face.mIndices[j]
			idx += 1
		}
	}

	// TODO: Extract bones


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


	append(
		&model.meshes,
		mesh_new(
			vertices,
			indices,
			MaterialHandle(strings.clone(transmute(string)mat_name.data[:mat_name.length])),
		),
	)
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
	delete(model.meshes)
	free(model)
}

@(export)
model_draw :: proc(model: ^Model, shader: ShaderProgram) {
	for &mesh in model.meshes {
		mesh_draw_with_material(mesh, shader)
	}
}
