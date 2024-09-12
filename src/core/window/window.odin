package window

import "base:runtime"
import "core:log"

import "core:fmt" // TODO: Remove

import gl "vendor:OpenGL"
import "vendor:glfw"

import "../../core"


WindowProperties :: struct {
	width, height:  i32,
	name:           cstring,
	event_callback: core.EventCallback,
}

Window :: struct {
	props:       ^WindowProperties,
	glfw_window: glfw.WindowHandle,
}

window_create :: proc(
	width, height: i32,
	name: cstring,
	event_callback: core.EventCallback,
) -> Window {
	if (event_callback == nil) {
		log.fatal("Window must have an event callback")
	}

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

	//  Callbacks
	props := new(WindowProperties)
	props.width = width
	props.height = height
	props.event_callback = event_callback
	glfw.SetWindowUserPointer(window, rawptr(props))

	glfw.SetWindowSizeCallback(window, proc "c" (window: glfw.WindowHandle, w, h: i32) {
		props := cast(^WindowProperties)glfw.GetWindowUserPointer(window)
		props.width = w
		props.height = h
		props.event_callback(core.WindowResizeEvent{w, h})
	})

	glfw.SetWindowCloseCallback(window, proc "c" (window: glfw.WindowHandle) {
		glfw.SetWindowShouldClose(window, glfw.TRUE)
	})

	glfw.SetKeyCallback(
		window,
		proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
			// TODO
		},
	)

	glfw.SetMouseButtonCallback(
		window,
		proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
			// TODO
		},
	)

	glfw.SetScrollCallback(
		window,
		proc "c" (window: glfw.WindowHandle, x, y: f64) {
			// TODO
		},
	)

	glfw.SetCursorPosCallback(
		window,
		proc "c" (window: glfw.WindowHandle, x, y: f64) {
			// TODO
		},
	)
	return Window{props, window}
}

window_destroy :: proc(using win: ^Window) {
	glfw.Terminate()
	glfw.DestroyWindow(glfw_window)
	free(props)
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
