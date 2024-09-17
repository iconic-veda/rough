package renderer

import "core:log"
// import glm "core:math/linalg/glsl"

import "../vendor/assimp"

Model :: struct {
	meshes: [dynamic]^Mesh,
}

@(export)
model_new :: proc(file_path: string) -> ^Model {
	model := new(Model)

	scene := assimp.import_file(
		file_path,
		u32(assimp.PostProcessSteps.Triangulate | assimp.PostProcessSteps.FlipUVs),
	)
	defer {
		// assimp.release_import(scene)
		assimp.free_scene(scene)
		log.info("Unload model's scene completed!")
	}

	if scene == nil ||
	   scene.mFlags & u32(assimp.SceneFlags.INCOMPLETE) != 0 ||
	   scene.mRootNode == nil {
		log.fatal("Failed to load model: %s", file_path)
	}


	process_node :: proc(node: ^assimp.Node, scene: ^assimp.Scene, model: ^Model) {
		// Process meshes if any
		for i: u32 = 0; i < node.mNumMeshes; i += 1 {
			assimp_mesh := scene.mMeshes[node.mMeshes[i]]
			vertices: []Vertex = make([]Vertex, assimp_mesh.mNumVertices + 1)
			indices: []u32 = make([]u32, assimp_mesh.mNumFaces * 1024)

			for vertex_idx: u32 = 0; vertex_idx < assimp_mesh.mNumVertices; vertex_idx += 1 {
				vertices[vertex_idx].position = assimp_mesh.mVertices[vertex_idx].xyz
				vertices[vertex_idx].normal = assimp_mesh.mNormals[vertex_idx].xyz

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

			// TODO: Extract material/textures
			append(&model.meshes, mesh_new(vertices, indices, nil))
		}

		// Process child obj
		for child_idx: u32 = 0; child_idx < node.mNumChildren; child_idx += 1 {
			process_node(node.mChildren[child_idx], scene, model)
		}
	}
	process_node(scene.mRootNode, scene, model)
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
