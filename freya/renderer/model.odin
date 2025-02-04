package renderer

import "core:log"
import "core:path/filepath"
// import glm "core:math/linalg/glsl"

import "../vendor/assimp"

Model :: struct {
	meshes: [dynamic]^Mesh,
}

@(export)
model_new :: proc(file_path: string) -> ^Model {
	log.infof("Loading model: {}", file_path)
	model := new(Model)

	scene := assimp.import_file(
		file_path,
		u32(assimp.PostProcessSteps.Triangulate | assimp.PostProcessSteps.FlipUVs),
	)
	defer {
		// assimp.release_import(scene)
		assimp.free_scene(scene)
		log.info("Model loaded, unload model's scene completed!")
	}

	if scene == nil ||
	   scene.mFlags & u32(assimp.SceneFlags.INCOMPLETE) != 0 ||
	   scene.mRootNode == nil {
		log.fatalf("Failed to load model: {}", file_path)
	}

	process_node :: proc(
		node: ^assimp.Node,
		scene: ^assimp.Scene,
		model: ^Model,
		base_path: string,
	) {
		// Process meshes if any
		for i: u32 = 0; i < node.mNumMeshes; i += 1 {
			assimp_mesh := scene.mMeshes[node.mMeshes[i]]
			vertices: []Vertex = make([]Vertex, assimp_mesh.mNumVertices + 1)
			indices: []u32 = make([]u32, assimp_mesh.mNumFaces * 1024)

			for vertex_idx: u32 = 0; vertex_idx < assimp_mesh.mNumVertices; vertex_idx += 1 {
				vertices[vertex_idx].position = assimp_mesh.mVertices[vertex_idx].xyz
				vertices[vertex_idx].normal = assimp_mesh.mNormals[vertex_idx].xyz

				// NOTE: We only care about the first set of texture coordinates
				if assimp_mesh.mTextureCoords[0] != nil {
					vertices[vertex_idx].tex_coords = assimp_mesh.mTextureCoords[0][vertex_idx].xy
				} else {
					vertices[vertex_idx].tex_coords = {0.0, 0.0}
				}
			}

			num_indices := 0 // TODO: Find better way (maybe dynamic arrays?)
			for face_idx: u32 = 0; face_idx < assimp_mesh.mNumFaces; face_idx += 1 {
				face := assimp_mesh.mFaces[face_idx]
				for indice_idx: u32 = 0; indice_idx < face.mNumIndices; indice_idx += 1 {
					indices[num_indices] = face.mIndices[indice_idx]
					num_indices += 1
				}
			}
			indices = indices[:num_indices]

			textures: []TextureHandle = nil
			if assimp_mesh.mMaterialIndex >= 0 {
				material := scene.mMaterials[assimp_mesh.mMaterialIndex]
				load_textures :: proc(
					material: ^assimp.Material,
					type: assimp.TextureType,
					base_path: string,
				) -> []TextureHandle {
					texture_count := assimp.get_material_textureCount(material, type)
					textures: []TextureHandle = make([]TextureHandle, texture_count)
					for texture_idx: u32 = 0; texture_idx < texture_count; texture_idx += 1 {
						object_relative_path: assimp.String
						mapping: assimp.TextureMapping
						uvindex: u32
						blend: f64
						op: assimp.TextureOp
						mapmode: assimp.TextureMapMode
						assimp.get_material_texture(
							material,
							type,
							texture_idx,
							&object_relative_path,
							&mapping,
							&uvindex,
							&blend,
							&op,
							&mapmode,
						)

						texture_path := filepath.join(
							{
								base_path,
								transmute(string)object_relative_path.data[:object_relative_path.length],
							},
						)
						// TODO: Use assimp mapping/uvindex/blend/op/mapmode to create texture
						#partial switch type {
						case assimp.TextureType.DIFFUSE:
							textures[texture_idx] = resource_manager_add(
								texture_path,
								TextureType.Diffuse,
							)
						case assimp.TextureType.SPECULAR:
							textures[texture_idx] = resource_manager_add(
								texture_path,
								TextureType.Specular,
							)
						case assimp.TextureType.NORMALS:
							textures[texture_idx] = resource_manager_add(
								texture_path,
								TextureType.Normal,
							)
						case assimp.TextureType.HEIGHT:
							textures[texture_idx] = resource_manager_add(
								texture_path,
								TextureType.Height,
							)
						case:
							log.fatal("Texture type not supported", type)
						}
					}
					return textures
				}

				textures_diffuse := load_textures(material, assimp.TextureType.DIFFUSE, base_path)
				textures_specular := load_textures(
					material,
					assimp.TextureType.SPECULAR,
					base_path,
				)
				textures_normals := load_textures(material, assimp.TextureType.NORMALS, base_path)
				textures_height := load_textures(material, assimp.TextureType.HEIGHT, base_path)


				textures = make(
					[]TextureHandle,
					len(textures_diffuse) +
					len(textures_specular) +
					len(textures_normals) +
					len(textures_height),
				)
				copy(textures, textures_diffuse)
				copy(textures[len(textures_diffuse):], textures_specular)
				copy(textures[len(textures_specular)+len(textures_diffuse):], textures_normals)
				copy(textures[len(textures_specular)+len(textures_diffuse)+len(textures_normals):], textures_height)
			}
			append(&model.meshes, mesh_new(vertices, indices, textures))
		}

		// Process child obj
		for child_idx: u32 = 0; child_idx < node.mNumChildren; child_idx += 1 {
			process_node(node.mChildren[child_idx], scene, model, base_path)
		}
	}

	base_path := filepath.dir(file_path)
	process_node(scene.mRootNode, scene, model, base_path)
	return model
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
		mesh_draw(mesh, shader)
	}
}
