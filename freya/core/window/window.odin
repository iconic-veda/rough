package window

import "../../core"

import "core:log"

import "vendor:glfw"

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
			props := cast(^WindowProperties)glfw.GetWindowUserPointer(window)
			switch (action) {
			case glfw.REPEAT:
				props.event_callback(core.KeyPressEvent{core.KeyCode(key), true})
			case glfw.PRESS:
				props.event_callback(core.KeyPressEvent{core.KeyCode(key), false})
			case glfw.RELEASE:
				props.event_callback(core.KeyReleaseEvent{core.KeyCode(key)})
			}
		},
	)

	glfw.SetMouseButtonCallback(
		window,
		proc "c" (window: glfw.WindowHandle, button, action, mods: i32) {
			props := cast(^WindowProperties)glfw.GetWindowUserPointer(window)
			switch (action) {
			case glfw.PRESS:
				props.event_callback(core.MouseButtonPressEvent{core.MouseButton(button)})
			case glfw.RELEASE:
				props.event_callback(core.MouseButtonReleaseEvent{core.MouseButton(button)})
			}
		},
	)

	glfw.SetScrollCallback(
		window,
		proc "c" (window: glfw.WindowHandle, x, y: f64) {
			props := cast(^WindowProperties)glfw.GetWindowUserPointer(window)
			props.event_callback(core.MouseScrollEvent{f32(x), f32(y)})
		},
	)

	glfw.SetCursorPosCallback(window, proc "c" (window: glfw.WindowHandle, x, y: f64) {
		props := cast(^WindowProperties)glfw.GetWindowUserPointer(window)
		props.event_callback(core.MouseMoveEvent{f32(x), f32(y)})
	})
	return Window{props, window}
}

window_get_time :: proc() -> f64 {
	return glfw.GetTime()
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
