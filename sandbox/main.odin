package sandbox

import "freya"

import "core:log"

import "core:math"
import "core:time"

import glm "core:math/linalg/glsl"


ASPECT_RATIO: f32 = 800.0 / 600.0
camera_controller: freya.OpenGLCameraController


shader: freya.ShaderProgram
grid_shader: freya.ShaderProgram

cube: ^freya.Mesh
model: ^freya.Model

LIGHT: freya.Light = {
	position = {1.2, 1.0, 2.0},
	ambient  = {0.2, 0.2, 0.2},
	diffuse  = {0.5, 0.5, 0.5},
	specular = {1.0, 1.0, 1.0},
}

MATERIAL: freya.Material = {
	ambient   = {1.0, 0.5, 0.31},
	diffuse   = {1.0, 0.5, 0.31},
	specular  = {0.5, 0.5, 0.5},
	shininess = 32.0,
}

theta: f32 = 0.0
stop_watch: time.Stopwatch

initialize :: proc() {
	time.stopwatch_start(&stop_watch)

	log.info("Hello from lib")

	camera_controller = freya.new_camera_controller(ASPECT_RATIO)

	shader = freya.shader_new(#load("../shaders/vertex.glsl"), #load("../shaders/fragment.glsl"))

	grid_shader = freya.shader_new(
		#load("../shaders/grid_vert.glsl"),
		#load("../shaders/grid_frag.glsl"),
	)

	textures: []freya.Texture = {freya.texture_new("assets/textures/diamond_block.png", .Diffuse)}
	cube = freya.new_cube_mesh(textures)

	// model = freya.model_new("assets/models/rat/street_rat.obj")
	model = freya.model_new("assets/models/human/FinalBaseMesh.obj")
}

shutdown :: proc() {
	freya.shader_delete(shader)
	freya.shader_delete(grid_shader)

	freya.mesh_free(cube)
	freya.model_free(model)

	time.stopwatch_stop(&stop_watch)
}

update :: proc(dt: f64) {
	duration := time.stopwatch_duration(stop_watch)

	{
		theta += f32(dt)
	}

	{
		freya.camera_on_update(&camera_controller, dt)
	}

	{ 	// Update light color
		time := time.duration_seconds(duration)
		light_color := glm.vec3 {
			2.0 * glm.cos(math.sin(f32(time) * 2.0)),
			0.7 * glm.cos(math.sin(f32(time) * 0.7)),
			1.3 * glm.cos(math.sin(f32(time) * 1.3)),
		}

		LIGHT.diffuse = light_color * glm.vec3(0.5)
		LIGHT.ambient = light_color * glm.vec3(2.0)
	}
}

draw :: proc() {
	freya.clear_screen({0.2, 0.2, 0.2, 1.0})

	{ 	// Setup model matrix && submit data to draw
		model_transform :=
			glm.mat4Rotate({0.0, 1.0, 0.0}, theta) *
			glm.mat4Scale({2, 2, 2}) *
			glm.mat4Translate({0.0, 0.0, 0.0})

		freya.shader_use(shader)
		freya.shader_set_uniform(shader, "light.position", &LIGHT.position)
		freya.shader_set_uniform(shader, "view_pos", &camera_controller._position)

		freya.shader_set_uniform(shader, "light.ambient", &LIGHT.ambient)
		freya.shader_set_uniform(shader, "light.diffuse", &LIGHT.diffuse)
		freya.shader_set_uniform(shader, "light.specular", &LIGHT.specular)

		// Set Material
		freya.shader_set_uniform(shader, "material.ambient", &MATERIAL.ambient)
		freya.shader_set_uniform(shader, "material.diffuse", &MATERIAL.diffuse)
		freya.shader_set_uniform(shader, "material.specular", &MATERIAL.specular)
		freya.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)

		freya.shader_set_uniform(shader, "model", &model_transform)
		freya.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		freya.shader_set_uniform(shader, "view", &camera_controller.view_mat)
		// freya.mesh_draw(cube, shader)
		freya.model_draw(model, shader)
	}

	{ 	// Draw grid
		freya.shader_use(grid_shader)
		freya.shader_set_uniform(grid_shader, "projection", &camera_controller.proj_mat)
		freya.shader_set_uniform(grid_shader, "view", &camera_controller.view_mat)
		freya.draw_grid()
	}
}

on_event :: proc(ev: freya.Event) {
	#partial switch e in ev {
	case freya.WindowResizeEvent:
		{
			ASPECT_RATIO = f32(e.width) / f32(e.height)
		}
	}

	freya.camera_on_event(&camera_controller, ev)
}

main :: proc() {
	freya.game = freya.Game {
		init     = initialize,
		shutdown = shutdown,
		update   = update,
		draw     = draw,
		on_event = on_event,
	}

	freya.start_engine()
}
