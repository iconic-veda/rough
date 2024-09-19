package main

import engn "engine"
import rndr "renderer"

import "core:log"

SHOULD_RUN: bool = true

Game :: struct {
	init:     proc(),
	update:   proc(delta_time: f64),
	draw:     proc(),
	shutdown: proc(),
	on_event: proc(ev: engn.Event),
}

@(export)
game: Game

event_callback :: proc(ev: engn.Event) {
	#partial switch e in ev {
	case engn.WindowResizeEvent:
		{
			rndr.on_window_resize(e.width, e.height)
		}
	case engn.KeyPressEvent:
		{
			if e.code == engn.KeyCode.Escape {
				SHOULD_RUN = false
				return
			}
		}
	}

	game.on_event(ev)
}


@(export)
start_engine :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	engn.WINDOW = engn.window_create(800, 600, "Freya Engine", event_callback)
	defer engn.window_destroy(&engn.WINDOW)

	rndr.initialize_context()

	engn.window_toggle_cursor(&engn.WINDOW)

	rndr.resource_manager_new()
	defer rndr.resource_manager_free()

	game.init()

	last_frame: f64 = 0.0
	for !engn.window_should_close(&engn.WINDOW) && SHOULD_RUN {
		now := engn.window_get_time()
		delta_time := now - last_frame
		last_frame = now

		engn.window_poll_events()
		game.update(delta_time)
		game.draw()

		engn.window_swapbuffers(&engn.WINDOW)
	}
	game.shutdown()
}
