package sandbox

import "freya"

// import "core:math"
import "core:strconv"
import "core:strings"
import "core:time"

import glm "core:math/linalg/glsl"


ASPECT_RATIO: f32 = 800.0 / 600.0
camera_controller: freya.OpenGLCameraController

shader: freya.ShaderProgram
grid_shader: freya.ShaderProgram
light_bulb_shader: freya.ShaderProgram

cube: ^freya.Mesh
model: ^freya.Model

light_cube: ^freya.Mesh


POINT_LIGHTS: [4]freya.PointLight = {
	{
		position = {0.7, 0.2, 2.0},
		ambient = {0.05, 0.05, 0.05},
		diffuse = {0.8, 0.8, 0.8},
		specular = {1.0, 1.0, 1.0},
		constant = 1.0,
		linear = 0.09,
		quadratic = 0.032,
	},
	{
		position = {2.3, -3.3, -4.0},
		ambient = {0.05, 0.05, 0.05},
		diffuse = {0.8, 0.8, 0.8},
		specular = {1.0, 1.0, 1.0},
		constant = 1.0,
		linear = 0.09,
		quadratic = 0.032,
	},
	{
		position = {-4.0, 2.0, -12.0},
		ambient = {0.05, 0.05, 0.05},
		diffuse = {0.8, 0.8, 0.8},
		specular = {1.0, 1.0, 1.0},
		constant = 1.0,
		linear = 0.09,
		quadratic = 0.032,
	},
	{
		position = {0.0, 0.0, -3.0},
		ambient = {0.05, 0.05, 0.05},
		diffuse = {0.8, 0.8, 0.8},
		specular = {1.0, 1.0, 1.0},
		constant = 1.0,
		linear = 0.09,
		quadratic = 0.032,
	},
}

DIR_LIGHT: freya.DirectionalLight = {
	direction = {-0.2, -1.0, -0.3},
	ambient   = {0.05, 0.05, 0.05},
	diffuse   = {0.4, 0.4, 0.4},
	specular  = {0.5, 0.5, 0.5},
}

MATERIAL: freya.Material = {
	shininess = 120.0,
}

theta: f32 = 0.0
stop_watch: time.Stopwatch

initialize :: proc() {
	time.stopwatch_start(&stop_watch)

	camera_controller = freya.new_camera_controller(ASPECT_RATIO)

	{ 	// Initialize shaders
		shader = freya.shader_new(
			#load("../shaders/vertex.glsl"),
			#load("../shaders/fragment.glsl"),
		)

		grid_shader = freya.shader_new(
			#load("../shaders/grid_vert.glsl"),
			#load("../shaders/grid_frag.glsl"),
		)

		light_bulb_shader = freya.shader_new(
			#load("../shaders/light_bulb_vert.glsl"),
			#load("../shaders/light_bulb_frag.glsl"),
		)
	}

	{ 	// Iniziale model and cube
		model = freya.model_new("assets/models/train/Models/OBJ format/train-locomotive-c.obj")

		textures: []freya.Texture = {
			freya.texture_new("assets/textures/container2.png", .Diffuse),
			freya.texture_new("assets/textures/container2_specular_color.png", .Specular),
		}
		cube = freya.new_cube_mesh(textures)
	}

	{ 	// Initialize light bulbs
		light_cube = freya.new_cube_mesh(nil)
	}
}

shutdown :: proc() {
	freya.shader_delete(shader)
	freya.shader_delete(grid_shader)
	freya.shader_delete(light_bulb_shader)

	freya.model_free(model)
	freya.mesh_free(cube)
	freya.mesh_free(light_cube)

	time.stopwatch_stop(&stop_watch)
}

update :: proc(dt: f64) {
	_ = time.stopwatch_duration(stop_watch)

	{
		theta += f32(dt)
	}

	{
		freya.camera_on_update(&camera_controller, dt)
	}
}

draw :: proc() {
	freya.clear_screen({0.2, 0.2, 0.2, 1.0})

	{ 	// Light bulb
		freya.shader_use(light_bulb_shader)
		freya.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		freya.shader_set_uniform(shader, "view", &camera_controller.view_mat)

		for light in POINT_LIGHTS {
			model_transform := glm.mat4Translate(light.position) * glm.mat4Scale({0.1, 0.1, 0.1})
			freya.shader_set_uniform(light_bulb_shader, "model", &model_transform)
			freya.mesh_draw(light_cube, light_bulb_shader)
		}
	}

	{ 	// Setup & draw cube
		model_transform := glm.mat4(1.0)

		freya.shader_use(shader)
		freya.shader_set_uniform(shader, "view_pos", &camera_controller._position)

		{ 	// Set lights parameters
			freya.shader_set_uniform(shader, "directional_light.direction", &DIR_LIGHT.direction)
			freya.shader_set_uniform(shader, "directional_light.ambient", &DIR_LIGHT.diffuse)
			freya.shader_set_uniform(shader, "directional_light.diffuse", &DIR_LIGHT.ambient)
			freya.shader_set_uniform(shader, "directional_light.specular", &DIR_LIGHT.specular)

			for &light, idx in POINT_LIGHTS {
				buf: [4]u8
				str_idx := strconv.itoa(buf[:], idx)
				prefix := strings.concatenate({"point_lights[", str_idx, "]"})

				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".position"}),
					&light.position,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".ambient"}),
					&light.ambient,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".diffuse"}),
					&light.diffuse,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".specular"}),
					&light.specular,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".constant"}),
					light.constant,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".linear"}),
					light.linear,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".quadratic"}),
					light.quadratic,
				)
			}
		}

		// Set Material
		freya.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)

		freya.shader_set_uniform(shader, "model", &model_transform)
		freya.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		freya.shader_set_uniform(shader, "view", &camera_controller.view_mat)
		freya.mesh_draw(cube, shader)
	}

	{ 	// Setup model matrix && submit data to draw
		model_transform := glm.mat4Translate({3, 0, 3}) //* glm.mat4Scale({100, 100, 100})

		freya.shader_use(shader)
		freya.shader_set_uniform(shader, "view_pos", &camera_controller._position)

		{ 	// Set lights parameters
			freya.shader_set_uniform(shader, "directional_light.direction", &DIR_LIGHT.direction)
			freya.shader_set_uniform(shader, "directional_light.ambient", &DIR_LIGHT.diffuse)
			freya.shader_set_uniform(shader, "directional_light.diffuse", &DIR_LIGHT.ambient)
			freya.shader_set_uniform(shader, "directional_light.specular", &DIR_LIGHT.specular)

			for &light, idx in POINT_LIGHTS {
				buf: [4]u8
				str_idx := strconv.itoa(buf[:], idx)
				prefix := strings.concatenate({"point_lights[", str_idx, "]"})

				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".position"}),
					&light.position,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".ambient"}),
					&light.ambient,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".diffuse"}),
					&light.diffuse,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".specular"}),
					&light.specular,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".constant"}),
					light.constant,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".linear"}),
					light.linear,
				)
				freya.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".quadratic"}),
					light.quadratic,
				)
			}
		}

		// Set Material
		freya.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)

		freya.shader_set_uniform(shader, "model", &model_transform)
		freya.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		freya.shader_set_uniform(shader, "view", &camera_controller.view_mat)
		freya.model_draw(model, shader)
	}

	// { 	// Draw grid
	// 	freya.shader_use(grid_shader)
	// 	freya.shader_set_uniform(grid_shader, "projection", &camera_controller.proj_mat)
	// 	freya.shader_set_uniform(grid_shader, "view", &camera_controller.view_mat)
	// 	freya.draw_grid()
	// }
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
