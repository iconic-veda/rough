package renderer

import glm "core:math/linalg/glsl"

import engine "../engine"

@(private)
RENDERER: ^Renderer = nil

Renderer :: struct {
	no_material_shader: ShaderProgram,
	grid_shader:        ShaderProgram,
}

renderer_initialize :: proc() {
	RENDERER = new(Renderer)

	RENDERER.no_material_shader = shader_new(
		#load("../../shaders/textures_material_vertex.glsl"),
		#load("../../shaders/textures_material_fragment.glsl"),
	)

	RENDERER.grid_shader = shader_new(
		#load("../../shaders/grid_vert.glsl"),
		#load("../../shaders/grid_frag.glsl"),
	)

}

renderer_shutdown :: proc() {
	shader_delete(RENDERER.no_material_shader)
	shader_delete(RENDERER.grid_shader)

	free(RENDERER)
}


renderer_draw_grid :: proc(view_mat, proj_mat: ^glm.mat4) {
	shader_use(RENDERER.grid_shader)
	shader_set_uniform(RENDERER.grid_shader, "view", view_mat)
	shader_set_uniform(RENDERER.grid_shader, "projection", proj_mat)
	draw_grid()
}

renderer_draw_model :: proc {
	renderer_draw_model_simple,
// renderer_draw_model_pbr,
}

renderer_draw_model_simple :: proc(
	model: ^Model,
	ambient_light: ^Light,
	transform: ^engine.Transform,
	view_pos: ^glm.vec3,
	view_mat, proj_mat: ^glm.mat4,
) {
	shader_use(RENDERER.no_material_shader)
	shader_set_uniform(RENDERER.no_material_shader, "model", &transform.model_matrix)
	shader_set_uniform(RENDERER.no_material_shader, "projection", proj_mat)
	shader_set_uniform(RENDERER.no_material_shader, "view", view_mat)

	shader_set_uniform(RENDERER.no_material_shader, "light.position", &ambient_light.position)
	shader_set_uniform(RENDERER.no_material_shader, "light.ambient", &ambient_light.ambient)
	shader_set_uniform(RENDERER.no_material_shader, "light.diffuse", &ambient_light.diffuse)
	shader_set_uniform(RENDERER.no_material_shader, "light.specular", &ambient_light.specular)

	model_draw(model, RENDERER.no_material_shader)
}

renderer_draw_model_pbr :: proc(model: ^Model, transform: ^engine.Transform) {
	//  TODO: Implement
}
