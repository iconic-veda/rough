package renderer

import "core:fmt"
import glm "core:math/linalg/glsl"
import "core:strings"

import engine "../engine"

@(private)
RENDERER: ^Renderer = nil

Renderer :: struct {
	outline_shader:  ShaderProgram,
	material_shader: ShaderProgram,
	grid_shader:     ShaderProgram,
}

renderer_initialize :: proc() {
	RENDERER = new(Renderer)

	RENDERER.material_shader = shader_new(
		#load("../../shaders/textures_material_vertex.glsl"),
		#load("../../shaders/textures_material_fragment.glsl"),
	)

	RENDERER.outline_shader = shader_new(
		#load("../../shaders/textures_material_vertex.glsl"),
		#load("../../shaders/single_color_fragment.glsl"),
	)

	RENDERER.grid_shader = shader_new(
		#load("../../shaders/grid_vert.glsl"),
		#load("../../shaders/grid_frag.glsl"),
	)

}

renderer_shutdown :: proc() {
	shader_delete(RENDERER.outline_shader)
	shader_delete(RENDERER.material_shader)
	shader_delete(RENDERER.grid_shader)

	free(RENDERER)
}


renderer_draw_grid :: proc(view_mat, proj_mat: ^glm.mat4) {
	shader_use(RENDERER.grid_shader)
	shader_set_uniform(RENDERER.grid_shader, "view", view_mat)
	shader_set_uniform(RENDERER.grid_shader, "projection", proj_mat)
	draw_grid()
}

renderer_draw_model :: proc(
	model: ^Model,
	ambient_light: ^Light,
	animator: ^Animator,
	transform: ^engine.Transform,
	view_pos: ^glm.vec3,
	view_mat, proj_mat: ^glm.mat4,
) {
	shader_use(RENDERER.material_shader)
	shader_set_uniform(RENDERER.material_shader, "model", &transform.model_matrix)
	shader_set_uniform(RENDERER.material_shader, "projection", proj_mat)
	shader_set_uniform(RENDERER.material_shader, "view", view_mat)

	shader_set_uniform(RENDERER.material_shader, "light.position", &ambient_light.position)
	shader_set_uniform(RENDERER.material_shader, "light.ambient", &ambient_light.ambient)
	shader_set_uniform(RENDERER.material_shader, "light.diffuse", &ambient_light.diffuse)
	shader_set_uniform(RENDERER.material_shader, "light.specular", &ambient_light.specular)


	if animator != nil {
		transforms := animator.final_bone_matrices
		for i in 0 ..< len(transforms) {
			builder := strings.builder_make()
			strings.write_string(&builder, "finalBonesMatrices[")
			strings.write_int(&builder, i)
			strings.write_string(&builder, "]")

			uniform_name := strings.to_string(builder)
			shader_set_uniform(RENDERER.material_shader, uniform_name, &transforms[i])
		}
		shader_set_uniform(RENDERER.material_shader, "hasAnimation", f32(1.0))
	} else {
		shader_set_uniform(RENDERER.material_shader, "hasAnimation", f32(0.0))
	}


	model_draw(model, RENDERER.material_shader)
}

renderer_draw_model_outlined :: proc(
	model: ^Model,
	ambient_light: ^Light,
	animator: ^Animator,
	transform: ^engine.Transform,
	view_pos: ^glm.vec3,
	view_mat, proj_mat: ^glm.mat4,
) {
	shader_use(RENDERER.material_shader)

	enable_stencil_testing()
	shader_set_uniform(RENDERER.material_shader, "projection", proj_mat)
	shader_set_uniform(RENDERER.material_shader, "view", view_mat)
	shader_set_uniform(RENDERER.material_shader, "model", &transform.model_matrix)

	shader_set_uniform(RENDERER.material_shader, "light.position", &ambient_light.position)
	shader_set_uniform(RENDERER.material_shader, "light.ambient", &ambient_light.ambient)
	shader_set_uniform(RENDERER.material_shader, "light.diffuse", &ambient_light.diffuse)
	shader_set_uniform(RENDERER.material_shader, "light.specular", &ambient_light.specular)

	if animator != nil {
		transforms := animator.final_bone_matrices
		for i in 0 ..< len(transforms) {
			builder := strings.builder_make()
			strings.write_string(&builder, "finalBonesMatrices[")
			strings.write_int(&builder, i)
			strings.write_string(&builder, "]")

			uniform_name := strings.to_string(builder)
			shader_set_uniform(RENDERER.material_shader, uniform_name, &transforms[i])
		}
		shader_set_uniform(RENDERER.material_shader, "hasAnimation", f32(1.0))
	} else {
		shader_set_uniform(RENDERER.material_shader, "hasAnimation", f32(0.0))
	}
	model_draw(model, RENDERER.material_shader)

	disable_stencil_testing()
	shader_use(RENDERER.outline_shader)
	shader_set_uniform(RENDERER.outline_shader, "projection", proj_mat)
	shader_set_uniform(RENDERER.outline_shader, "view", view_mat)

	if animator != nil {
		transforms := animator.final_bone_matrices
		for i in 0 ..< len(transforms) {
			builder := strings.builder_make()
			strings.write_string(&builder, "finalBonesMatrices[")
			strings.write_int(&builder, i)
			strings.write_string(&builder, "]")

			uniform_name := strings.to_string(builder)
			shader_set_uniform(RENDERER.outline_shader, uniform_name, &transforms[i])
		}
		shader_set_uniform(RENDERER.outline_shader, "hasAnimation", f32(1.0))
	} else {
		shader_set_uniform(RENDERER.outline_shader, "hasAnimation", f32(0.0))
	}

	newtransform :=
		glm.mat4Translate(transform.position) *
		glm.mat4Rotate({1, 0, 0}, transform.rotation.x) *
		glm.mat4Rotate({0, 1, 0}, transform.rotation.y) *
		glm.mat4Rotate({0, 0, 1}, transform.rotation.z) *
		glm.mat4Scale(transform.scale * 1.01)

	shader_set_uniform(RENDERER.outline_shader, "model", &newtransform)
	model_draw(model, RENDERER.outline_shader)
	reset_stencil_testing()
}
