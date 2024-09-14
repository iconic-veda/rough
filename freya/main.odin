package main

import "core"
import "libgame"

import win "core/window"
import rndr "renderer"

import "core:log"

SHOULD_RUN: bool = true

event_callback :: proc(ev: core.Event) {
	#partial switch e in ev {
	case core.WindowResizeEvent:
		{
			rndr.on_window_resize(e.width, e.height)
		}
	case core.KeyPressEvent:
		{
			if e.code == core.KeyCode.Escape {
			    SHOULD_RUN = false
				return
			}
		}
	}

	libgame.on_event(ev)
}

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	window := win.window_create(800, 600, "Freya Engine", event_callback)
	defer win.window_destroy(&window)

	rndr.initialize_context()
	rndr.enable_capabilities({.DEPTH_TEST, .STENCIL_TEST})

	libgame.initialize()

	last_frame: f64 = 0.0
	for !win.window_should_close(&window) && SHOULD_RUN {
		now := win.window_get_time()
		delta_time := now - last_frame
		last_frame = now

		win.window_poll_events()
		libgame.update(delta_time)
		libgame.draw()

		win.window_swapbuffers(&window)
	}
	libgame.shutdown()
}
