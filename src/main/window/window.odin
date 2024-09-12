package window

import "core:log"

import gl "vendor:OpenGL"
import "vendor:glfw"

Window :: struct {
	width, height: i32,
	name:          cstring,
	glfw_window:   glfw.WindowHandle,
}

window_create :: proc(width, height: i32, name: cstring) -> Window {
	if (glfw.Init() != glfw.TRUE) {
		log.fatal("Failed to initialize GLFW")
	}

	glfw.WindowHint(glfw.RESIZABLE, glfw.TRUE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 4)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 6)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

	window := glfw.CreateWindow(width, height, name, nil, nil)
	if window == nil {
		log.fatal("Failed to create GLFW window")
	}

	glfw.MakeContextCurrent(window)
	glfw.SwapInterval(1)

	// TODO: Event system
	glfw.SetKeyCallback(window, _callback_key)
	glfw.SetWindowRefreshCallback(window, _window_refresh)

	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
	w, h := glfw.GetFramebufferSize(window)
	gl.Viewport(0, 0, w, h)

	return Window{width, height, name, window}
}

window_destroy :: proc(using win: ^Window) {
	glfw.Terminate()
	glfw.DestroyWindow(glfw_window)
}

window_should_close :: proc(using win: ^Window) -> bool {
	return glfw.WindowShouldClose(glfw_window) == glfw.TRUE
}

window_swapbuffers :: proc(using win: ^Window) {
	glfw.SwapBuffers(glfw_window)
}

window_poll_events :: proc() {
	glfw.PollEvents()
}


_callback_key :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	if action == glfw.PRESS && key == glfw.KEY_ESCAPE {
		glfw.SetWindowShouldClose(window, glfw.TRUE)
	}
}

ASPECT_RATIO: f32 = 800.0 / 600.0
_window_refresh :: proc "c" (window: glfw.WindowHandle) {
	w, h: i32
	w, h = glfw.GetWindowSize(window)
	gl.Viewport(0, 0, w, h)
	ASPECT_RATIO = f32(w) / f32(h)
}
