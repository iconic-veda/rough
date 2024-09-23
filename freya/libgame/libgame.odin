package libgame

import engn "../engine"
import rndr "../renderer"

import "core:log"
import "core:dynlib"
import glm "core:math/linalg/glsl"


GameSymbols :: struct {
    initialize: proc "odin" (),
    shutdown: proc "odin" (),
    update: proc "odin" (dt: f64),
    draw: proc "odin" (),
    on_event: proc "odin" (ev: engn.Event),

    _game_handle: dynlib.Library
}

GAME: GameSymbols

load_libgame :: proc() {
when ODIN_OS == .Windows {
    count, ok := dynlib.initialize_symbols(&GAME, "libgame.dll", "libgame_", "_game_handle")
} else {
    log.fatal("Os not supported yet!")
}
    if !ok {
        log.fatalf("Could not initialize libgame library, error: {}, os_error: {}", dynlib.last_error())
    }
}

unload_libgame :: proc() {
    dynlib.unload_library(GAME._game_handle)
}
