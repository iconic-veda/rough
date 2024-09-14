package main

import eng "engine"
import "libgame"
import rndr "renderer"

import "core:log"

SHOULD_RUN: bool = true

event_callback :: proc(ev: eng.Event) {
	#partial switch e in ev {
	case eng.WindowResizeEvent:
		{
			rndr.on_window_resize(e.width, e.height)
		}
	case eng.KeyPressEvent:
		{
			if e.code == eng.KeyCode.Escape {
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

	window := eng.window_create(800, 600, "Freya Engine", event_callback)
	defer eng.window_destroy(&window)

	rndr.initialize_context()
	rndr.enable_capabilities({.DEPTH_TEST, .STENCIL_TEST})

	libgame.initialize()

	last_frame: f64 = 0.0
	for !eng.window_should_close(&window) && SHOULD_RUN {
		now := eng.window_get_time()
		delta_time := now - last_frame
		last_frame = now

		eng.window_poll_events()
		libgame.update(delta_time)
		libgame.draw()

		eng.window_swapbuffers(&window)
	}
	libgame.shutdown()
}
