package freya

import eng "engine"
import rndr "renderer"

import "core:log"

SHOULD_RUN: bool = true

Game :: struct {
	init:     proc(),
	update:   proc(delta_time: f64),
	draw:     proc(),
	shutdown: proc(),
	on_event: proc(ev: eng.Event),
}

@(export)
game: Game

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

	game.on_event(ev)
}


@(export)
start_engine :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	window := eng.window_create(800, 600, "Freya Engine", event_callback)
	defer eng.window_destroy(&window)

	rndr.initialize_context()
	rndr.enable_capabilities({.DEPTH_TEST, .STENCIL_TEST})

	game.init()

	last_frame: f64 = 0.0
	for !eng.window_should_close(&window) && SHOULD_RUN {
		now := eng.window_get_time()
		delta_time := now - last_frame
		last_frame = now

		eng.window_poll_events()
		game.update(delta_time)
		game.draw()

		eng.window_swapbuffers(&window)
	}
	game.shutdown()
}
