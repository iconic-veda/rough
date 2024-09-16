package sandbox

import "freya"

import "core:log"

import glm "core:math/linalg/glsl"

cube: ^freya.Mesh

shader: freya.ShaderProgram
grid_shader: freya.ShaderProgram

ASPECT_RATIO: f32 = 800.0 / 600.0
theta: f32 = 0.0

initialize :: proc() {
	log.info("Hello from lib")

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
}

draw :: proc() {
	freya.clear_screen({0.2, 0.2, 0.2, 1.0})

	model :=
		glm.mat4Rotate({1.0, 1.0, 1.0}, theta) *
		glm.mat4Scale({0.5, 0.5, 0.5}) *
		glm.mat4Translate({0.0, 10.0, 0.0})
	view: glm.mat4 = glm.mat4LookAt({10, 1, 10}, {1, 1, 1}, {0, 1, 0})
	projection := glm.mat4Perspective(glm.radians(f32(45)), ASPECT_RATIO, 0.001, 1000.0)

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
	case freya.MouseMoveEvent:
		{
			// fmt.printfln("Mouse moved to: ({}, {})", e.x, e.y)
		}
	}
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
