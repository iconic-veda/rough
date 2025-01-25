package animagik

import gui_panels "panels"

import freya "../freya"
import engine "../freya/engine"
import renderer "../freya/renderer"

import glm "core:math/linalg/glsl"
import "core:strconv"
import "core:strings"

import ecs "../freya/vendor/YggECS"
import im "../freya/vendor/odin-imgui"

ASPECT_RATIO: f32 = 800.0 / 600.0

camera_controller: engine.OpenGLCameraController
shader: renderer.ShaderProgram
grid_shader: renderer.ShaderProgram
viewport_fb: ^renderer.FrameBuffer

scene_panel: ^gui_panels.ScenePanel
assets_panel: ^gui_panels.AssetsPanel

entities_world: ^ecs.World

MATERIAL: renderer.Material = {
	shininess = 120.0,
}

DIR_LIGHT: renderer.DirectionalLight = {
	direction = {-0.2, -1.0, -0.3},
	ambient   = {0.05, 0.05, 0.05},
	diffuse   = {0.4, 0.4, 0.4},
	specular  = {0.5, 0.5, 0.5},
}

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

GuiLayer :: struct {
	using base: engine.Layer,
}

gui_layer_new :: proc() -> ^GuiLayer {
	layer := new(GuiLayer)
	layer.initialize = initialize
	layer.shutdown = shutdown
	layer.update = update
	layer.render = render
	layer.imgui_render = imgui_render
	layer.on_event = on_event
	layer.is_active = true
	return layer
}

initialize :: proc() {
	renderer.enable_capabilities(
		{
			renderer.OpenGlCapability.CULL_FACE,
			renderer.OpenGlCapability.DEPTH_TEST,
			renderer.OpenGlCapability.STENCIL_TEST,
			renderer.OpenGlCapability.BLEND,
		},
	)

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
	}

	entities_world = ecs.new_world()

	{ 	// TODO: Remove this code, only to try gui
		ent := ecs.add_entity(entities_world)
		model_component := renderer.model_new("assets/models/backpack/backpack.obj")
		ecs.add_component(entities_world, ent, model_component)
		ecs.add_component(
			entities_world,
			ent,
			engine.Transform {
				glm.vec3{0.0, 0.0, 0.0},
				glm.vec3{0.0, 0.0, 0.0},
				glm.vec3{1.0, 1.0, 1.0},
				glm.mat4Translate({0.0, 0.0, 0.0}),
			},
		)
	}

	{ 	// Gui panels
		scene_panel = gui_panels.scene_panel_new(entities_world)
		assets_panel = gui_panels.assets_panel_new(renderer.RESOURCE_MANAGER)
	}
}

shutdown :: proc() {
	renderer.shader_delete(shader)
	renderer.shader_delete(grid_shader)

	renderer.framebuffer_free(viewport_fb)

	{ 	// Clear entities world
		// TODO: Get all entities and free them in the correct way
		ecs.delete_world(entities_world)
	}

	{ 	// Gui panels
		gui_panels.scene_panel_destroy(scene_panel)
		gui_panels.assets_panel_destroy(assets_panel)
	}
}

update :: proc(dt: f64) {
	{
		// TODO: Update entities
	}

	{
		if engine.is_button_pressed(engine.MouseButton.ButtonMiddle) {
			engine.camera_on_update(&camera_controller, dt)
		}
	}
}

render :: proc() {
	renderer.framebuffer_bind(viewport_fb)
	renderer.clear_screen({0.1, 0.1, 0.1, 1.0})

	{ 	// Render models
		for archetype in ecs.query(
			entities_world,
			ecs.has(^renderer.Model),
			ecs.has(engine.Transform),
		) {
			for eid, _ in archetype.entities {
				model := ecs.get_component_cast(
					entities_world,
					eid,
					^renderer.Model,
					^renderer.Model,
				)

				transform := ecs.get_component_cast(
					entities_world,
					eid,
					engine.Transform,
					engine.Transform,
				)

				renderer.shader_use(shader)
				renderer.shader_set_uniform(shader, "view_pos", &camera_controller._position)

				{ 	// Set lights parameters
					renderer.shader_set_uniform(
						shader,
						"directional_light.direction",
						&DIR_LIGHT.direction,
					)
					renderer.shader_set_uniform(
						shader,
						"directional_light.ambient",
						&DIR_LIGHT.diffuse,
					)
					renderer.shader_set_uniform(
						shader,
						"directional_light.diffuse",
						&DIR_LIGHT.ambient,
					)
					renderer.shader_set_uniform(
						shader,
						"directional_light.specular",
						&DIR_LIGHT.specular,
					)

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

				renderer.shader_set_uniform(shader, "material.shininess", MATERIAL.shininess)
				renderer.shader_set_uniform(shader, "model", &transform.model_matrix)
				renderer.shader_set_uniform(shader, "projection", &camera_controller.proj_mat)
				renderer.shader_set_uniform(shader, "view", &camera_controller.view_mat)
				renderer.model_draw(model, shader)
			}
		}
	}

	{ 	// Draw grid
		renderer.shader_use(grid_shader)
		renderer.shader_set_uniform(grid_shader, "view", &camera_controller.view_mat)
		renderer.shader_set_uniform(grid_shader, "projection", &camera_controller.proj_mat)
		renderer.draw_grid()
	}
	renderer.framebuffer_unbind()
}

imgui_render :: proc() {
	window_flags: im.WindowFlags = {
		im.WindowFlag.NoTitleBar,
		im.WindowFlag.NoCollapse,
		im.WindowFlag.NoResize,
		im.WindowFlag.NoMove,
		im.WindowFlag.NoBringToFrontOnFocus,
		im.WindowFlag.NoNavFocus,
		im.WindowFlag.MenuBar,
	}

	{ 	// Docking stuff
		viewport := im.GetMainViewport()
		im.SetNextWindowPos(viewport.WorkPos)
		im.SetNextWindowSize(viewport.WorkSize)
		im.SetNextWindowViewport(viewport._ID)

		im.PushStyleVar(im.StyleVar.WindowRounding, 0.0)
		im.PushStyleVar(im.StyleVar.WindowBorderSize, 0.0)

		dockspace_flags: im.DockNodeFlags = {im.DockNodeFlag.PassthruCentralNode}

		im.Begin("DockSpace Demo", nil, window_flags)
		im.PopStyleVar(2)

		dockspace_id := im.GetID("MyDockSpace")
		im.DockSpace(dockspace_id, im.Vec2{0, 0}, dockspace_flags)

		if im.BeginMenuBar() {
			if im.BeginMenu("Quit") {
				freya.SHOULD_RUN = false
				im.EndMenu()
			}

			if im.BeginMenu("File") {
				im.EndMenu()
			}
			im.EndMenuBar()
		}

		im.End()
	}

	im.Begin("Viewport", nil)
	win_width := im.GetContentRegionAvail().x
	win_height := im.GetContentRegionAvail().y
	renderer.framebuffer_rescale(viewport_fb, i32(win_width), i32(win_height))
	im.Image(
		im.TextureID(uintptr(viewport_fb.texture.id)),
		im.Vec2{win_width, win_height},
		im.Vec2{0, 1},
		im.Vec2{1, 0},
	)
	im.End()

	{ 	// Gui panels
		gui_panels.scene_panel_render(scene_panel)
		gui_panels.assets_panel_render(assets_panel)
	}
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
