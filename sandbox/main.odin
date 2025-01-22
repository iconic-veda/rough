package sandbox

import freya "../freya"
import engine "../freya/engine"
import renderer "../freya/renderer"

import im "../freya/vendor/odin-imgui"
import "../freya/vendor/odin-imgui/imgui_impl_glfw"
import "../freya/vendor/odin-imgui/imgui_impl_opengl3"

import "core:strconv"
import "core:strings"
import "core:time"

import glm "core:math/linalg/glsl"

DISABLE_DOCKING :: #config(DISABLE_DOCKING, false)

ASPECT_RATIO: f32 = 800.0 / 600.0
camera_controller: engine.OpenGLCameraController

shader: renderer.ShaderProgram
grid_shader: renderer.ShaderProgram
light_bulb_shader: renderer.ShaderProgram

cube: ^renderer.Mesh
model: ^renderer.Model

light_cube: ^renderer.Mesh

viewport_fb: ^renderer.FrameBuffer


POINT_LIGHTS: [4]renderer.PointLight = {
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

DIR_LIGHT: renderer.DirectionalLight = {
	direction = {-0.2, -1.0, -0.3},
	ambient   = {0.05, 0.05, 0.05},
	diffuse   = {0.4, 0.4, 0.4},
	specular  = {0.5, 0.5, 0.5},
}

MATERIAL: renderer.Material = {
	shininess = 120.0,
}

theta: f32 = 0.0
stop_watch: time.Stopwatch

imgui_io: ^im.IO

initialize :: proc() {
	time.stopwatch_start(&stop_watch)

	renderer.enable_capabilities(
		{
			renderer.OpenGlCapability.CULL_FACE,
			renderer.OpenGlCapability.DEPTH_TEST,
			renderer.OpenGlCapability.STENCIL_TEST,
			renderer.OpenGlCapability.BLEND,
		},
	)

	{ 	// Initialize imgui
		im.CHECKVERSION()
		im.CreateContext()
		imgui_io = im.GetIO()
		imgui_io.ConfigFlags += {.NavEnableKeyboard}
		when !DISABLE_DOCKING {
			imgui_io.ConfigFlags += {.DockingEnable}

			style := im.GetStyle()
			style.WindowRounding = 0
			style.Colors[im.Col.WindowBg].w = 1
		}

		im.StyleColorsDark()

		imgui_impl_glfw.InitForOpenGL(engine.WINDOW.glfw_window, true)
		imgui_impl_opengl3.Init()
	}

	camera_controller = engine.new_camera_controller(ASPECT_RATIO)

	viewport_fb = renderer.framebuffer_new(
		800,
		600,
		{renderer.FrameBufferAttachment.Color, renderer.FrameBufferAttachment.DepthStencil},
	)

	{ 	// Initialize shaders
		shader = renderer.shader_new(
			#load("../shaders/vertex.glsl"),
			#load("../shaders/fragment.glsl"),
		)

		grid_shader = renderer.shader_new(
			#load("../shaders/grid_vert.glsl"),
			#load("../shaders/grid_frag.glsl"),
		)

		light_bulb_shader = renderer.shader_new(
			#load("../shaders/light_bulb_vert.glsl"),
			#load("../shaders/light_bulb_frag.glsl"),
		)
	}

	{ 	// Iniziale model and cube
		model = renderer.model_new(
			"assets/models/backpack/backpack.obj", // "assets/models/train/Models/OBJ format/train-electric-bullet-a.obj",
		)

		textures: []renderer.TextureHandle = {
			renderer.resource_manager_add(
				"assets/textures/container2.png",
				renderer.TextureType.Diffuse,
			),
			renderer.resource_manager_add(
				"assets/textures/container2_specular.png",
				renderer.TextureType.Specular,
			),
		}
		cube = renderer.new_cube_mesh(textures)
	}

	{ 	// Initialize light bulbs
		light_cube = renderer.new_cube_mesh(nil)
	}
}

shutdown :: proc() {
	renderer.shader_delete(shader)
	renderer.shader_delete(grid_shader)
	renderer.shader_delete(light_bulb_shader)

	renderer.model_free(model)
	renderer.mesh_free(cube)
	renderer.mesh_free(light_cube)

	time.stopwatch_stop(&stop_watch)

	renderer.framebuffer_free(viewport_fb)

	imgui_impl_glfw.Shutdown()
	imgui_impl_opengl3.Shutdown()
	im.DestroyContext()
}

update :: proc(dt: f64) {
	_ = time.stopwatch_duration(stop_watch)

	{ 	// Update imgui
		imgui_impl_opengl3.NewFrame()
		imgui_impl_glfw.NewFrame()
	}

	{
		theta += f32(dt)
	}

	{
		engine.camera_on_update(&camera_controller, dt)
	}
}

draw :: proc() {
	renderer.clear_screen({0.0, 0.0, 0.0, 1.0})

	{ 	// Draw imgui
		im.NewFrame()
		when !DISABLE_DOCKING {

			viewport := im.GetMainViewport()
			im.SetNextWindowPos(viewport.WorkPos)
			im.SetNextWindowSize(viewport.WorkSize)
			im.SetNextWindowViewport(viewport._ID)

			im.PushStyleVar(im.StyleVar.WindowRounding, 0.0)
			im.PushStyleVar(im.StyleVar.WindowBorderSize, 0.0)

			window_flags: im.WindowFlags = {
				im.WindowFlag.NoTitleBar,
				im.WindowFlag.NoCollapse,
				im.WindowFlag.NoResize,
				im.WindowFlag.NoMove,
				im.WindowFlag.NoBringToFrontOnFocus,
				im.WindowFlag.NoNavFocus,
			}

			dockspace_flags: im.DockNodeFlags = {im.DockNodeFlag.PassthruCentralNode}

			im.Begin("DockSpace Demo", nil, window_flags)
			im.PopStyleVar(2)

			dockspace_id := im.GetID("MyDockSpace")
			im.DockSpace(dockspace_id, im.Vec2{0, 0}, dockspace_flags)

			im.End()
		}

		im.ShowDemoWindow()

		im.Begin("Scene")
		win_width := im.GetContentRegionAvail().x
		win_height := im.GetContentRegionAvail().y

		im.Text("pointer = %x", &viewport_fb.texture.id)
		im.Text("size = %d x %d", win_width, win_height)

		renderer.framebuffer_rescale(viewport_fb, i32(win_width), i32(win_height))

		im.Image(
			im.TextureID(uintptr(viewport_fb.texture.id)),
			im.Vec2{win_width, win_height},
			im.Vec2{0, 1},
			im.Vec2{1, 0},
		)

		im.End()
		im.Render()
	}

	renderer.framebuffer_bind(viewport_fb)
	renderer.clear_screen({0.2, 0.2, 0.2, 1.0})
	{ 	// Light bulb
		renderer.shader_use(light_bulb_shader)
		renderer.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		renderer.shader_set_uniform(shader, "view", &camera_controller.view_mat)

		for light in POINT_LIGHTS {
			model_transform := glm.mat4Translate(light.position) * glm.mat4Scale({0.1, 0.1, 0.1})
			renderer.shader_set_uniform(light_bulb_shader, "model", &model_transform)
			renderer.mesh_draw(light_cube, light_bulb_shader)
		}
	}

	{ 	// Setup & draw cube
		model_transform := glm.mat4(1.0) //* glm.mat4Translate({0.0, 3, 0.0})

		renderer.shader_use(shader)
		renderer.shader_set_uniform(shader, "view_pos", &camera_controller._position)

		{ 	// Set lights parameters
			renderer.shader_set_uniform(
				shader,
				"directional_light.direction",
				&DIR_LIGHT.direction,
			)
			renderer.shader_set_uniform(shader, "directional_light.ambient", &DIR_LIGHT.diffuse)
			renderer.shader_set_uniform(shader, "directional_light.diffuse", &DIR_LIGHT.ambient)
			renderer.shader_set_uniform(shader, "directional_light.specular", &DIR_LIGHT.specular)

			for &light, idx in POINT_LIGHTS {
				buf: [4]u8
				str_idx := strconv.itoa(buf[:], idx)
				prefix := strings.concatenate({"point_lights[", str_idx, "]"})

				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".position"}),
					&light.position,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".ambient"}),
					&light.ambient,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".diffuse"}),
					&light.diffuse,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".specular"}),
					&light.specular,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".constant"}),
					light.constant,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".linear"}),
					light.linear,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".quadratic"}),
					light.quadratic,
				)
			}
		}

		// Set Material
		renderer.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)

		renderer.shader_set_uniform(shader, "model", &model_transform)
		renderer.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		renderer.shader_set_uniform(shader, "view", &camera_controller.view_mat)
		renderer.mesh_draw(cube, shader)
	}

	{ 	// Setup model matrix && submit data to draw
		model_transform := glm.mat4Translate({5, 3, 5}) //* glm.mat4Scale({100, 100, 100})

		renderer.shader_use(shader)
		renderer.shader_set_uniform(shader, "view_pos", &camera_controller._position)

		{ 	// Set lights parameters
			renderer.shader_set_uniform(
				shader,
				"directional_light.direction",
				&DIR_LIGHT.direction,
			)
			renderer.shader_set_uniform(shader, "directional_light.ambient", &DIR_LIGHT.diffuse)
			renderer.shader_set_uniform(shader, "directional_light.diffuse", &DIR_LIGHT.ambient)
			renderer.shader_set_uniform(shader, "directional_light.specular", &DIR_LIGHT.specular)

			for &light, idx in POINT_LIGHTS {
				buf: [4]u8
				str_idx := strconv.itoa(buf[:], idx)
				prefix := strings.concatenate({"point_lights[", str_idx, "]"})

				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".position"}),
					&light.position,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".ambient"}),
					&light.ambient,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".diffuse"}),
					&light.diffuse,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".specular"}),
					&light.specular,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".constant"}),
					light.constant,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".linear"}),
					light.linear,
				)
				renderer.shader_set_uniform(
					shader,
					strings.concatenate({prefix, ".quadratic"}),
					light.quadratic,
				)
			}
		}

		// Set Material
		renderer.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)

		renderer.shader_set_uniform(shader, "model", &model_transform)
		renderer.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
		renderer.shader_set_uniform(shader, "view", &camera_controller.view_mat)
		renderer.model_draw(model, shader)
	}

	{ 	// Draw grid
		renderer.shader_use(grid_shader)
		renderer.shader_set_uniform(grid_shader, "view", &camera_controller.view_mat)
		renderer.shader_set_uniform(grid_shader, "projection", &camera_controller.proj_mat)
		renderer.draw_grid()
	}
	renderer.framebuffer_unbind()

	imgui_impl_opengl3.RenderDrawData(im.GetDrawData())
}

on_event :: proc(ev: engine.Event) {
	#partial switch e in ev {
	case engine.WindowResizeEvent:
		{
			ASPECT_RATIO = f32(e.width) / f32(e.height)
		}

	case engine.KeyPressEvent:
		{
			if e.code == engine.KeyCode.P {
				engine.window_toggle_cursor(&engine.WINDOW)
			}
		}
	}

	engine.camera_on_event(&camera_controller, ev)
}

main :: proc() {
	freya.start_engine(
		freya.Game {
			init = initialize,
			shutdown = shutdown,
			update = update,
			draw = draw,
			on_event = on_event,
		},
	)
}
