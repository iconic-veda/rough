package core

import "core"
import win "core/window"
import rndr "renderer"

import "core:fmt"
import "core:log"
import "core:time"

import glm "core:math/linalg/glsl"

event_callback :: proc(ev: core.Event) {
	switch e in ev {
	case core.WindowResizeEvent:
		{rndr.on_window_resize(e.width, e.height)}
	}
}

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	window := win.window_create(800, 600, "Freya Engine", event_callback)
	defer win.window_destroy(&window)
	rndr.initialize_context()

	shader := rndr.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))
	defer rndr.shader_delete(shader)

	vertices: []rndr.Vertex = {
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
	indices: []u32 = {
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
	textures: []rndr.Texture = {rndr.texture_new("assets/textures/diamond_block.png", .Diffuse)}

	quad := rndr.mesh_new(vertices, indices, textures)
	defer rndr.mesh_free(quad)

	rndr.enable_capabilities({.DEPTH_TEST, .STENCIL_TEST})

	watch: time.Stopwatch
	time.stopwatch_start(&watch)
	for !win.window_should_close(&window) {
		win.window_poll_events()
		rndr.clear_screen({0.28, 0.28, 0.28, 1.0})
		{
			// Update
			raw_duration := time.stopwatch_duration(watch)
			theta := f32(time.duration_seconds(raw_duration))

			// Draw
			model := glm.mat4Rotate({1.0, 1.0, 1.0}, f32(theta))
			view: glm.mat4 = glm.mat4LookAt({0, 10, 0}, {0, 0, -1.0}, {0, 1, 0})
			projection := glm.mat4Perspective(glm.radians(f32(45)), 800 / 600, 0.01, 1000.0)

			rndr.shader_use(shader)
			rndr.shader_set_uniform(shader, "model", &model)
			rndr.shader_set_uniform(shader, "projection", &projection)
			rndr.shader_set_uniform(shader, "view", &view)
			rndr.mesh_draw(quad, shader)
		}
		win.window_swapbuffers(&window)
	}
}
