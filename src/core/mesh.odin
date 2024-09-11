package core

import "core:log"

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"

Vertex :: struct {
	position: glm.vec3,
	normal:   glm.vec3,
	color:    glm.vec3,
	// tex_coords: glm.vec2,
}

Texture :: struct {
	id:   uint,
	type: string,
}

Mesh :: struct {
	vertices:         []Vertex,
	indices:          []u32,
	// textures:         []Texture,

	// Private fields
	_vao, _vbo, _ebo: u32,
	_binding_index:   u32,
}

mesh_new :: proc {
	mesh_new_explicit,
	mesh_new_from_obj_file,
}

mesh_new_from_obj_file :: proc(obj_path: string) -> Mesh {
	unimplemented("Not yet defined how to import objects") // TODO
}

mesh_new_explicit :: proc(
	vertices: []Vertex,
	indices: []u32,
	// textures: []Texture,
	allocator := context.allocator,
) -> ^Mesh {
	m := new(Mesh, allocator)
	m.vertices = vertices
	m.indices = indices
	// m.textures = textures
	_mesh_setup_buffers(m)
	return m
}


mesh_draw :: proc(m: ^Mesh, shader: ShaderProgram) {
	gl.BindVertexArray(m._vao)
	defer gl.BindVertexArray(0)
	gl.DrawElements(gl.TRIANGLES, i32(len(m.indices)), gl.UNSIGNED_INT, rawptr(uintptr(0)))
}

// Private mesh procedures
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
	gl.VertexArrayAttribFormat(m._vao, 2, 3, gl.FLOAT, gl.FALSE, u32(offset_of(Vertex, color)))
	gl.VertexArrayAttribBinding(m._vao, 2, m._binding_index)

	gl.BindVertexArray(0)
}
