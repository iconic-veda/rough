package freya

EventCallback :: #type proc(event: Event)

Event :: union {
	WindowResizeEvent,
}

WindowResizeEvent :: struct {
	width:  i32,
	height: i32,
}
