package sandbox

import eng "../freya/engine"
import rndr "../freya/renderer"

import "core:log"

import glm "core:math/linalg/glsl"

vertices: []rndr.Vertex
indices: []u32
textures: []rndr.Texture

quad: ^rndr.Mesh
shader: rndr.ShaderProgram

ASPECT_RATIO: f32 = 800.0 / 600.0
theta: f32 = 0.0

@(export)
initialize :: proc() {
	log.info("Hello from lib")

	vertices = {
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, -1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, -1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, -1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, -1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
		{{-1, +1, -1}, {0.0, 0.0, 1.0}, {0.0, 1.0}},
		{{+1, +1, -1}, {0.0, 0.0, 1.0}, {1.0, 1.0}},
		{{-1, +1, +1}, {0.0, 0.0, 1.0}, {0.0, 0.0}},
		{{+1, +1, +1}, {0.0, 0.0, 1.0}, {1.0, 0.0}},
	}
	indices = {
		0,
		1,
		2,
		1,
		2,
		3, // Face 1
		4,
		5,
		6,
		5,
		6,
		7, // Face 2
		8,
		9,
		10,
		9,
		10,
		11, // Face 3
		12,
		13,
		14,
		13,
		14,
		15, // Face 4
		16,
		17,
		18,
		17,
		18,
		19, // Face 5
		20,
		21,
		22,
		21,
		22,
		23, // Face 6
	}
	textures = {rndr.texture_new("assets/textures/wall.jpg", .Diffuse)}

	shader = rndr.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))
	quad = rndr.mesh_new(vertices, indices, textures)
}

@(export)
shutdown :: proc() {
	rndr.mesh_free(quad)
	rndr.shader_delete(shader)
	// log.info("Goodbye from lib")
}

@(export)
update :: proc(dt: f64) {
	theta += f32(dt)
}

@(export)
draw :: proc() {
	rndr.clear_screen({0.2, 0.2, 0.2, 1.0})

	model := glm.mat4Rotate({1.0, 1.0, 1.0}, theta)
	view: glm.mat4 = glm.mat4LookAt({0, 10, 0}, {0, 0, -1.0}, {0, 1, 0})
	projection := glm.mat4Perspective(glm.radians(f32(45)), ASPECT_RATIO, 0.01, 1000.0)

	rndr.shader_use(shader)
	rndr.shader_set_uniform(shader, "model", &model)
	rndr.shader_set_uniform(shader, "projection", &projection)
	rndr.shader_set_uniform(shader, "view", &view)
	rndr.mesh_draw(quad, shader)
}

@(export)
on_event :: proc(ev: eng.Event) {
	#partial switch e in ev {
	case eng.WindowResizeEvent:
		{
			ASPECT_RATIO = f32(e.width) / f32(e.height)
		}
	case eng.MouseMoveEvent:
		{
			// fmt.printfln("Mouse moved to: ({}, {})", e.x, e.y)
		}
	}
}
