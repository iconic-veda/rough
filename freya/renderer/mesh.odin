package renderer

import "core:log"
import "core:mem"

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"


Vertex :: struct {
	position:   glm.vec3,
	normal:     glm.vec3,
	// color:      glm.vec3,
	tex_coords: glm.vec2,
	tangent:    glm.vec3,
	bitanget:   glm.vec3,
}

Mesh :: struct {
	vertices:         []Vertex,
	indices:          []u32,
	material:         MaterialHandle,

	// Private fields
	_vao, _vbo, _ebo: u32,
	_binding_index:   u32,
	_allocator:       mem.Allocator,
}

mesh_new :: proc {
	mesh_new_explicit,
}

@(export)
mesh_free :: proc(m: ^Mesh) {
	gl.DeleteVertexArrays(1, &m._vao)
	gl.DeleteBuffers(1, &m._vbo)
	gl.DeleteBuffers(1, &m._ebo)
	free(m, m._allocator) // Is it ok ?
}


@(export)
mesh_new_explicit :: proc(
	vertices: []Vertex,
	indices: []u32,
	material: MaterialHandle,
	allocator := context.allocator,
) -> ^Mesh {
	m := new(Mesh, allocator)
	m.vertices = vertices
	m.indices = indices
	m.material = material
	m._allocator = allocator
	_mesh_setup_buffers(m)
	return m
}

@(export)
mesh_draw :: proc(m: ^Mesh, shader: ShaderProgram) {
	log.error("mesh_draw not implemented")
	// for texture_handle, idx in m.textures {
	// 	texture, err := resource_manager_get(texture_handle)
	// 	if err != ResourceManagerError.NoError {
	// 		continue
	// 	}

	// 	name: string
	// 	switch texture.type {
	// 	case TextureType.Diffuse:
	// 		name = "material.diffuse"
	// 	case TextureType.Specular:
	// 		name = "material.specular"
	// 	case TextureType.Normal:
	// 		name = "material.normal"
	// 	case TextureType.Height:
	// 		name = "material.height"
	// 	}

	// 	shader_set_uniform(shader, name, i32(idx))
	// 	gl.ActiveTexture(gl.TEXTURE0 + u32(idx))
	// 	gl.BindTexture(gl.TEXTURE_2D, texture.id)
	// }
	// gl.ActiveTexture(gl.TEXTURE0)

	// gl.BindVertexArray(m._vao)
	// gl.DrawElements(gl.TRIANGLES, i32(len(m.indices)), gl.UNSIGNED_INT, rawptr(uintptr(0)))
	// gl.BindVertexArray(0)

	// assert(gl.GetError() == gl.NO_ERROR, "OpenGL error")
}

@(export)
mesh_draw_with_material :: proc(m: ^Mesh, shader: ShaderProgram) {
	material, err := resource_manager_get(m.material)
	if err != ResourceManagerError.NoError {
		log.error("Failed to get material")
		return
	}

	{ 	// Diffuse
		diffuse, err := resource_manager_get_texture(material.diffuse_texture)
		if err == ResourceManagerError.NoError {
			shader_set_uniform(shader, "material.diffuse", 0)
			gl.ActiveTexture(gl.TEXTURE0)
			gl.BindTexture(gl.TEXTURE_2D, diffuse.id)
		}
	}

	{ 	// Specular
		specular, err := resource_manager_get_texture(material.specular_texture)
		if err == ResourceManagerError.NoError {
			shader_set_uniform(shader, "material.specular", 1)
			gl.ActiveTexture(gl.TEXTURE0 + 1)
			gl.BindTexture(gl.TEXTURE_2D, specular.id)
		}
	}

	{ 	// Normal
		height, err := resource_manager_get_texture(material.height_texture)
		if err == ResourceManagerError.NoError {
			shader_set_uniform(shader, "material.height", 2)
			gl.ActiveTexture(gl.TEXTURE0 + 2)
			gl.BindTexture(gl.TEXTURE_2D, height.id)
		}
	}

	{ 	// Ambient
		ambient, err := resource_manager_get_texture(material.ambient_texture)
		if err == ResourceManagerError.NoError {
			shader_set_uniform(shader, "material.ambient", 3)
			gl.ActiveTexture(gl.TEXTURE0 + 3)
			gl.BindTexture(gl.TEXTURE_2D, ambient.id)
		}
	}

	{ 	// Shininess
		shader_set_uniform(shader, "material.shininess", material.shininess)
	}


	gl.ActiveTexture(gl.TEXTURE0)

	gl.BindVertexArray(m._vao)
	gl.DrawElements(gl.TRIANGLES, i32(len(m.indices)), gl.UNSIGNED_INT, rawptr(uintptr(0)))
	gl.BindVertexArray(0)

	assert(gl.GetError() == gl.NO_ERROR, "OpenGL error")
}

// Private mesh procedures
@(private = "file")
_mesh_setup_buffers :: proc(m: ^Mesh) {
	// Create vao
	gl.CreateVertexArrays(1, &m._vao)
	gl.BindVertexArray(m._vao)

	// Create vbo
	gl.CreateBuffers(1, &m._vbo)
	gl.NamedBufferData(
		m._vbo,
		size_of(Vertex) * len(m.vertices),
		raw_data(m.vertices),
		gl.STATIC_DRAW,
	)

	// Create ebo
	gl.CreateBuffers(1, &m._ebo)
	gl.NamedBufferData(m._ebo, size_of(u32) * len(m.indices), raw_data(m.indices), gl.STATIC_DRAW)

	// Bind vbo-ebo to vao
	gl.VertexArrayVertexBuffer(m._vao, m._binding_index, m._vbo, 0, size_of(Vertex))
	gl.VertexArrayElementBuffer(m._vao, m._ebo)

	gl.EnableVertexArrayAttrib(m._vao, 0)
	gl.VertexArrayAttribFormat(m._vao, 0, 3, gl.FLOAT, gl.FALSE, u32(offset_of(Vertex, position)))
	gl.VertexArrayAttribBinding(m._vao, 0, m._binding_index)

	gl.EnableVertexArrayAttrib(m._vao, 1)
	gl.VertexArrayAttribFormat(m._vao, 1, 3, gl.FLOAT, gl.FALSE, u32(offset_of(Vertex, normal)))
	gl.VertexArrayAttribBinding(m._vao, 1, m._binding_index)

	gl.EnableVertexArrayAttrib(m._vao, 2)
	gl.VertexArrayAttribFormat(
		m._vao,
		2,
		2,
		gl.FLOAT,
		gl.FALSE,
		u32(offset_of(Vertex, tex_coords)),
	)
	gl.VertexArrayAttribBinding(m._vao, 2, m._binding_index)

	gl.BindVertexArray(0)
}
