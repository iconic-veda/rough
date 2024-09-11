package core

import "core:log"

import "core:math/linalg"
import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"


// NOTE: Do i need to keep track of the shader's code source path?
ShaderProgram :: u32

shader_new :: proc(vertex_source, fragment_source: string) -> ShaderProgram {
	if program, ok := gl.load_shaders_source(vertex_source, fragment_source); ok {
		log.info("Shader program id =", program)
		return program
	} else {
		log.panic("Failed to load shader")
	}
}

shader_use :: proc(shader: ShaderProgram) {
	gl.UseProgram(shader)
}

shader_delete :: proc(shader: ShaderProgram) {
	gl.DeleteProgram(shader)
}

shader_set_uniform :: proc {
	_shader_set_uniform_bool,
	_shader_set_uniform_int,
	_shader_set_uniform_float,
	_shader_set_uniform_vec2,
	_shader_set_uniform_vec3,
	_shader_set_uniform_mat4,
}

_shader_set_uniform_bool :: proc(shader: ShaderProgram, name: cstring, value: bool) {
	gl.Uniform1i(gl.GetUniformLocation(shader, name), i32(value))
}

_shader_set_uniform_int :: proc(shader: ShaderProgram, name: cstring, value: i32) {
	gl.Uniform1i(gl.GetUniformLocation(shader, name), value)
}

_shader_set_uniform_float :: proc(shader: ShaderProgram, name: cstring, value: f32) {
	gl.Uniform1f(gl.GetUniformLocation(shader, name), value)
}

_shader_set_uniform_vec2 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.vec2) {
	gl.Uniform2f(gl.GetUniformLocation(shader, name), value.x, value.y)
}

_shader_set_uniform_vec3 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.vec3) {
	gl.Uniform3f(gl.GetUniformLocation(shader, name), value.x, value.y, value.z)
}

_shader_set_uniform_mat4 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.mat4) {
	gl.UniformMatrix4fv(gl.GetUniformLocation(shader, name), 1, gl.FALSE, raw_data(value))
}
