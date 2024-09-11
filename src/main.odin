package freya

import freya "core"
import "core:log"
import m "core:math"
import "core:math/linalg"
import glm "core:math/linalg/glsl"
import "core:os"

import "base:runtime"

import gl "vendor:OpenGL"
import "vendor:glfw"

ASPECT_RATIO: f32 = 800.0 / 600.0

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	if (glfw.Init() != glfw.TRUE) {
		log.error("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window := glfw.CreateWindow(800, 800, "freya", nil, nil)
	if window == nil {
		log.error("Failed to create GLFW window")
		return
	}
	defer glfw.DestroyWindow(window)

	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)

	{ 	// Callbacks
		glfw.SetKeyCallback(window, callback_key)
		glfw.SetWindowRefreshCallback(window, window_refresh)
	}

	gl.load_up_to(4, 6, glfw.gl_set_proc_address)

	w, h := glfw.GetFramebufferSize(window)
	gl.Viewport(0, 0, w, h)

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

	for !glfw.WindowShouldClose(window) {
		glfw.PollEvents()
		gl.ClearColor(0.28, 0.28, 0.28, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
		{
			model := glm.mat4Rotate({1.0, 1.0, 1.0}, f32(glfw.GetTime()))
			view: glm.mat4 = glm.mat4LookAt({0, 10, 0}, {0, 0, -1.0}, {0, 1, 0})
			projection := glm.mat4Perspective(glm.radians(f32(45)), ASPECT_RATIO, 0.01, 1000.0)

			freya.shader_use(shader)
			gl.Enable(gl.DEPTH_TEST)

			freya.shader_set_uniform(shader, "model", &model)
			freya.shader_set_uniform(shader, "projection", &projection)
			freya.shader_set_uniform(shader, "view", &view)
			freya.mesh_draw(quad, shader)
		}
		glfw.SwapBuffers(window)
	}
}

callback_key :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if action == glfw.PRESS && key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, glfw.TRUE)
	}
}

window_refresh :: proc "c" (window: glfw.WindowHandle) {
	context = runtime.default_context()
	w, h: i32
	w, h = glfw.GetWindowSize(window)
	gl.Viewport(0, 0, w, h)
	ASPECT_RATIO = f32(w) / f32(h)
}
