package sandbox

import "freya"

import "core:log"

import glm "core:math/linalg/glsl"

vertices: []freya.Vertex
indices: []u32
textures: []freya.Texture

quad: ^freya.Mesh
shader: freya.ShaderProgram

ASPECT_RATIO: f32 = 800.0 / 600.0
theta: f32 = 0.0

initialize :: proc() {
	log.info("Hello from lib")

	vertices = {
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
	}
	indices = {
		0,
		1,
		2,
		1,
		2,
		3, // Face 1
		4,
		5,
		6,
		5,
		6,
		7, // Face 2
		8,
		9,
		10,
		9,
		10,
		11, // Face 3
		12,
		13,
		14,
		13,
		14,
		15, // Face 4
		16,
		17,
		18,
		17,
		18,
		19, // Face 5
		20,
		21,
		22,
		21,
		22,
		23, // Face 6
	}
	textures = {freya.texture_new("assets/textures/wall.jpg", .Diffuse)}

	shader = freya.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))
	quad = freya.mesh_new(vertices, indices, textures)
}

shutdown :: proc() {
	freya.mesh_free(quad)
	freya.shader_delete(shader)
	// log.info("Goodbye from lib")
}

update :: proc(dt: f64) {
	theta += f32(dt)
}

draw :: proc() {
	freya.clear_screen({0.2, 0.2, 0.2, 1.0})

	model := glm.mat4Rotate({1.0, 1.0, 1.0}, theta)
	view: glm.mat4 = glm.mat4LookAt({0, 10, 0}, {0, 0, -1.0}, {0, 1, 0})
	projection := glm.mat4Perspective(glm.radians(f32(45)), ASPECT_RATIO, 0.01, 1000.0)

	freya.shader_use(shader)
	freya.shader_set_uniform(shader, "model", &model)
	freya.shader_set_uniform(shader, "projection", &projection)
	freya.shader_set_uniform(shader, "view", &view)
	freya.mesh_draw(quad, shader)
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
