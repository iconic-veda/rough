package libgame

import "../core"

when ODIN_OS == .Linux {
	foreign import game "build/libgame.so"
} else when ODIN_OS == .Windows {
	foreign import libgame "build/libgame.dll"
}

@(default_calling_convention = "odin")
foreign game {
	initialize :: proc() ---
	shutdown :: proc() ---

	update :: proc(dt: f64) ---
	draw :: proc() ---

	on_event :: proc(ev: core.Event) ---
}
