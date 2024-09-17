package freya

import glm "core:math/linalg/glsl"
import "core:mem"

Game :: struct {
	init:     proc(),
	update:   proc(delta_time: f64),
	draw:     proc(),
	shutdown: proc(),
	on_event: proc(ev: Event),
}

Vertex :: struct {
	position:   glm.vec3,
	normal:     glm.vec3,
	tex_coords: glm.vec2,
}

Model :: struct {
	meshes: [dynamic]^Mesh,
}

Mesh :: struct {
	vertices:         []Vertex,
	indices:          []u32,
	textures:         []^Texture,

	// Private fields
	_vao, _vbo, _ebo: u32,
	_binding_index:   u32,
	_allocator:       mem.Allocator,
}

Material :: struct {
	ambient, diffuse, specular: glm.vec3,
	shininess:                  f32,
}

Light :: struct {
	position, ambient, diffuse, specular: glm.vec3,
}


Texture :: struct {
	id:   u32,
	type: TextureType,
}

TextureType :: enum {
	Diffuse,
	Specular,
}

PerspectiveCamera :: struct {
	view_mat: glm.mat4,
	proj_mat: glm.mat4,

	// Camera vectors
	_up:      glm.vec3,
	_eye:     glm.vec3,
	_center:  glm.vec3,
}

OpenGLCameraController :: struct {
	using camera:       PerspectiveCamera,

	// Private
	_aspect_ratio:      f32,
	_fov:               f32,
	_near, _far:        f32,
	_yaw, _pitch:       f32,

	//
	_right:             glm.vec3,
	_forward:           glm.vec3,
	_position:          glm.vec3,

	//
	_rotation_speed:    f32,
	_translation_speed: f32,
}


ShaderProgram :: u32

when ODIN_OS == .Linux {
	foreign import freya "build/freya.so"
} else when ODIN_OS == .Windows {
	foreign import libgame "build/freya.dll"
}


@(default_calling_convention = "odin")
foreign freya {
	// Game
	game: Game
	start_engine :: proc() ---

	// Model bindings
	model_new :: proc(file_path: string) -> ^Model ---
	model_free :: proc(model: ^Model) ---
	model_draw :: proc(model: ^Model, shader: ShaderProgram) ---

	// Mesh bindings
	mesh_new_explicit :: proc(vertices: []Vertex, indices: []u32, textures: []Texture, allocator := context.allocator) -> ^Mesh ---
	mesh_free :: proc(m: ^Mesh) ---
	mesh_draw :: proc(m: ^Mesh, shader: ShaderProgram) ---
	new_cube_mesh :: proc(textures: []Texture) -> ^Mesh ---

	// Texture bindings
	texture_new :: proc(filename: cstring, type: TextureType) -> Texture ---

	// Shader bindings
	shader_new :: proc(vertex_source, fragment_source: string) -> ShaderProgram ---
	shader_use :: proc(shader: ShaderProgram) ---
	shader_delete :: proc(shader: ShaderProgram) ---

	_shader_set_uniform_bool :: proc(shader: ShaderProgram, name: cstring, value: bool) ---
	_shader_set_uniform_int :: proc(shader: ShaderProgram, name: cstring, value: i32) ---
	_shader_set_uniform_float :: proc(shader: ShaderProgram, name: cstring, value: f32) ---
	_shader_set_uniform_vec2 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.vec2) ---
	_shader_set_uniform_vec3 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.vec3) ---
	_shader_set_uniform_mat4 :: proc(shader: ShaderProgram, name: cstring, value: ^glm.mat4) ---


	// Renderer bindings
	clear_screen :: proc(color: glm.vec4) ---
	draw_grid :: proc() ---


	// Camera system
	camera_controller_new :: proc(aspect_ratio: f32, fov: f32, near, far: f32) -> OpenGLCameraController ---
	new_camera_controller :: proc(aspect_ratio: f32, fov: f32 = 45.0, near: f32 = 0.1, far: f32 = 1000.0) -> OpenGLCameraController ---
	camera_on_event :: proc(controller: ^OpenGLCameraController, event: Event) ---
	camera_on_update :: proc(controller: ^OpenGLCameraController, dt: f64) ---
}

mesh_new :: proc {
	mesh_new_explicit,
}

shader_set_uniform :: proc {
	_shader_set_uniform_bool,
	_shader_set_uniform_int,
	_shader_set_uniform_float,
	_shader_set_uniform_vec2,
	_shader_set_uniform_vec3,
	_shader_set_uniform_mat4,
}


////////////////////////////////////////
// Events

Event :: union {
	WindowResizeEvent,
	KeyPressEvent,
	KeyReleaseEvent,
	MouseButtonPressEvent,
	MouseButtonReleaseEvent,
	MouseMoveEvent,
	MouseScrollEvent,
}

WindowResizeEvent :: struct {
	width:  i32,
	height: i32,
}

// Keyboard events

KeyPressEvent :: struct {
	code:   KeyCode,
	repeat: bool,
}

KeyReleaseEvent :: struct {
	code: KeyCode,
}

// Mouse events

MouseButtonPressEvent :: struct {
	button: MouseButton,
}

MouseButtonReleaseEvent :: struct {
	button: MouseButton,
}

MouseMoveEvent :: struct {
	x: f32,
	y: f32,
}

MouseScrollEvent :: struct {
	x: f32,
	y: f32,
}


// KeyCodes

KeyCode :: enum {
	// From glfw3.h
	Space        = 32,
	Apostrophe   = 39, /* ' */
	Comma        = 44, /* , */
	Minus        = 45, /* - */
	Period       = 46, /* . */
	Slash        = 47, /* / */
	D0           = 48, /* 0 */
	D1           = 49, /* 1 */
	D2           = 50, /* 2 */
	D3           = 51, /* 3 */
	D4           = 52, /* 4 */
	D5           = 53, /* 5 */
	D6           = 54, /* 6 */
	D7           = 55, /* 7 */
	D8           = 56, /* 8 */
	D9           = 57, /* 9 */
	Semicolon    = 59, /* ; */
	Equal        = 61, /* = */
	A            = 65,
	B            = 66,
	C            = 67,
	D            = 68,
	E            = 69,
	F            = 70,
	G            = 71,
	H            = 72,
	I            = 73,
	J            = 74,
	K            = 75,
	L            = 76,
	M            = 77,
	N            = 78,
	O            = 79,
	P            = 80,
	Q            = 81,
	R            = 82,
	S            = 83,
	T            = 84,
	U            = 85,
	V            = 86,
	W            = 87,
	X            = 88,
	Y            = 89,
	Z            = 90,
	LeftBracket  = 91, /* [ */
	Backslash    = 92, /* \ */
	RightBracket = 93, /* ] */
	GraveAccent  = 96, /* ` */
	World1       = 161, /* non-US #1 */
	World2       = 162, /* non-US #2 */

	/* Function keys */
	Escape       = 256,
	Enter        = 257,
	Tab          = 258,
	Backspace    = 259,
	Insert       = 260,
	Delete       = 261,
	Right        = 262,
	Left         = 263,
	Down         = 264,
	Up           = 265,
	PageUp       = 266,
	PageDown     = 267,
	Home         = 268,
	End          = 269,
	CapsLock     = 280,
	ScrollLock   = 281,
	NumLock      = 282,
	PrintScreen  = 283,
	Pause        = 284,
	F1           = 290,
	F2           = 291,
	F3           = 292,
	F4           = 293,
	F5           = 294,
	F6           = 295,
	F7           = 296,
	F8           = 297,
	F9           = 298,
	F10          = 299,
	F11          = 300,
	F12          = 301,
	F13          = 302,
	F14          = 303,
	F15          = 304,
	F16          = 305,
	F17          = 306,
	F18          = 307,
	F19          = 308,
	F20          = 309,
	F21          = 310,
	F22          = 311,
	F23          = 312,
	F24          = 313,
	F25          = 314,

	/* Keypad */
	KP0          = 320,
	KP1          = 321,
	KP2          = 322,
	KP3          = 323,
	KP4          = 324,
	KP5          = 325,
	KP6          = 326,
	KP7          = 327,
	KP8          = 328,
	KP9          = 329,
	KPDecimal    = 330,
	KPDivide     = 331,
	KPMultiply   = 332,
	KPSubtract   = 333,
	KPAdd        = 334,
	KPEnter      = 335,
	KPEqual      = 336,
	LeftShift    = 340,
	LeftControl  = 341,
	LeftAlt      = 342,
	LeftSuper    = 343,
	RightShift   = 344,
	RightControl = 345,
	RightAlt     = 346,
	RightSuper   = 347,
	Menu         = 348,
}

// MouseCodes

MouseButton :: enum {
	// From glfw3.h
	Button0      = 0,
	Button1      = 1,
	Button2      = 2,
	Button3      = 3,
	Button4      = 4,
	Button5      = 5,
	Button6      = 6,
	Button7      = 7,
	ButtonLast   = Button7,
	ButtonLeft   = Button0,
	ButtonRight  = Button1,
	ButtonMiddle = Button2,
}
