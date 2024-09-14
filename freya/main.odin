package main

import "core"
import "libgame"

import win "core/window"
import rndr "renderer"

import "core:log"

event_callback :: proc(ev: core.Event) {
	switch e in ev {
	case core.WindowResizeEvent:
		{
			rndr.on_window_resize(e.width, e.height)
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

	fps_limit: f64 = 1 / 60.0
	last_frame, last_update: f64 = 0.0, 0.0
	for !win.window_should_close(&window) {
		now := win.window_get_time()
		delta_time := now - last_update

		win.window_poll_events()
		libgame.update(delta_time)

		if ((now - last_frame) >= fps_limit) {
			rndr.clear_screen({0.28, 0.28, 0.28, 1.0})

			libgame.draw()

			win.window_swapbuffers(&window)
			last_frame = now
		}
		last_update = now
	}
	libgame.shutdown()
}
