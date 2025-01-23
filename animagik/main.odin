package animagik

import freya "../freya"
import engine "../freya/engine"


main :: proc() {
	game := freya.Game{engine.layer_stk_new()}

	// Add layers here
	engine.layer_stk_push_layer(game.layer_stack, gui_layer_new())

	freya.start_engine(game)
}
