package sandbox

import "freya"

import "core:log"

import glm "core:math/linalg/glsl"


camera_controller: freya.OpenGLCameraController


cube: ^freya.Mesh

shader: freya.ShaderProgram
grid_shader: freya.ShaderProgram

ASPECT_RATIO: f32 = 800.0 / 600.0
theta: f32 = 0.0

initialize :: proc() {
	log.info("Hello from lib")


	camera_controller = freya.new_camera_controller(ASPECT_RATIO)

	shader = freya.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))

	grid_shader = freya.shader_new(
		#load("../shaders/grid_vert.glsl"),
		#load("../shaders/grid_frag.glsl"),
	)

	textures: []freya.Texture = {freya.texture_new("assets/textures/diamond_block.png", .Diffuse)}
	cube = freya.new_cube_mesh(textures)
}

shutdown :: proc() {
	freya.mesh_free(cube)
	freya.shader_delete(shader)
}

update :: proc(dt: f64) {
	theta += f32(dt)
	freya.camera_on_update(&camera_controller, dt)
}

draw :: proc() {
	freya.clear_screen({0.2, 0.2, 0.2, 1.0})

	model :=
		glm.mat4Rotate({0.0, 1.0, 0.0}, theta) *
		glm.mat4Scale({0.5, 0.5, 0.5}) *
		glm.mat4Translate({0.0, 10.0, 0.0})

	view := camera_controller.view_mat
	projection := camera_controller.proj_mat

	freya.shader_use(shader)
	freya.shader_set_uniform(shader, "model", &model)
	freya.shader_set_uniform(shader, "projection", &projection)
	freya.shader_set_uniform(shader, "view", &view)
	freya.mesh_draw(cube, shader)

	freya.shader_use(grid_shader)
	freya.shader_set_uniform(grid_shader, "projection", &projection)
	freya.shader_set_uniform(grid_shader, "view", &view)
	freya.draw_grid()
}

on_event :: proc(ev: freya.Event) {
	#partial switch e in ev {
	case freya.WindowResizeEvent:
		{
			ASPECT_RATIO = f32(e.width) / f32(e.height)
		}
	}

	freya.camera_on_event(&camera_controller, ev)
}

main :: proc() {
	freya.game = freya.Game {
		init     = initialize,
		shutdown = shutdown,
		update   = update,
		draw     = draw,
		on_event = on_event,
	}

	freya.start_engine()
}
