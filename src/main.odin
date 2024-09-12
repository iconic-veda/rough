package freya

import freya "main"
import win "main/window"

import "core:log"
import "core:time"

import glm "core:math/linalg/glsl"
import gl "vendor:OpenGL"

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	window := win.window_create(800, 600, "Freya Engine")

	shader := freya.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))
	defer freya.shader_delete(shader)

	vertices: []freya.Vertex = {
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
	textures: []freya.Texture = {
		freya.texture_new("assets/textures/diamond_block.png", freya.TextureType.Diffuse),
	}
	quad := freya.mesh_new(vertices, indices, textures)
	defer freya.mesh_free(quad)

	gl.Enable(gl.DEPTH_TEST)

	watch: time.Stopwatch
	time.stopwatch_start(&watch)
	for !win.window_should_close(&window) {
		win.window_poll_events()
		gl.ClearColor(0.28, 0.28, 0.28, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		{
			raw_duration := time.stopwatch_duration(watch)
			theta := f32(time.duration_seconds(raw_duration))

			model := glm.mat4Rotate({1.0, 1.0, 1.0}, f32(theta))
			view: glm.mat4 = glm.mat4LookAt({0, 10, 0}, {0, 0, -1.0}, {0, 1, 0})
			projection := glm.mat4Perspective(glm.radians(f32(45)), win.ASPECT_RATIO, 0.01, 1000.0)

			freya.shader_use(shader)
			freya.shader_set_uniform(shader, "model", &model)
			freya.shader_set_uniform(shader, "projection", &projection)
			freya.shader_set_uniform(shader, "view", &view)
			freya.mesh_draw(quad, shader)
		}
		win.window_swapbuffers(&window)
	}
	win.window_destroy(&window)
}
