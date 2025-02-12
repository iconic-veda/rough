package animagik

import gui_panels "panels"

import freya "../freya"
import engine "../freya/engine"
import renderer "../freya/renderer"

import glm "core:math/linalg/glsl"

import ecs "../freya/vendor/odin-ecs"
import im "../freya/vendor/odin-imgui"

ASPECT_RATIO: f32 = 800.0 / 600.0

camera_controller: engine.EditorCameraController
viewport_fb: ^renderer.FrameBuffer

scene_panel: ^gui_panels.ScenePanel

entities_world: ecs.Context

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

	camera_controller = engine.new_editor_camera_controller(ASPECT_RATIO)

	viewport_fb = renderer.framebuffer_new(
		800,
		600,
		{renderer.FrameBufferAttachment.Color, renderer.FrameBufferAttachment.DepthStencil},
	)

	entities_world = ecs.init_ecs()
	{ 	// TODO: Remove this code, only to try gui
		{
			ent := ecs.create_entity(&entities_world)
			model_component := renderer.model_new("assets/models/vampire/dancing_vampire.dae")
			ecs.add_component(&entities_world, ent, model_component)
			t := engine.Transform {
				glm.vec3{10.0, 0.0, 0.0},
				glm.vec3{0.0, 0.0, 0.0},
				glm.vec3{0.04, 0.04, 0.04},
				glm.mat4Translate({0.0, 0.0, 0.0}),
			}
			t.model_matrix =
				glm.mat4Translate(t.position) *
				glm.mat4Rotate({1, 0, 0}, t.rotation.x) *
				glm.mat4Rotate({0, 1, 0}, t.rotation.y) *
				glm.mat4Rotate({0, 0, 1}, t.rotation.z) *
				glm.mat4Scale(t.scale)
			ecs.add_component(&entities_world, ent, t)
			ecs.add_component(&entities_world, ent, engine.Name("Vampire"))
		}

		{
			ent := ecs.create_entity(&entities_world)
			model_component := renderer.model_new("assets/models/backpack/backpack.obj")
			ecs.add_component(&entities_world, ent, model_component)
			t := engine.Transform {
				glm.vec3{0.0, 0.0, 0.0},
				glm.vec3{0.0, 0.0, 0.0},
				glm.vec3{1, 1, 1},
				glm.mat4Translate({0.0, 0.0, 0.0}),
			}
			t.model_matrix =
				glm.mat4Translate(t.position) *
				glm.mat4Rotate({1, 0, 0}, t.rotation.x) *
				glm.mat4Rotate({0, 1, 0}, t.rotation.y) *
				glm.mat4Rotate({0, 0, 1}, t.rotation.z) *
				glm.mat4Scale(t.scale)
			ecs.add_component(&entities_world, ent, t)
			ecs.add_component(&entities_world, ent, engine.Name("Backpack"))
		}
	}


	{ 	// Gui panels
		scene_panel = gui_panels.scene_panel_new(&entities_world)
	}
}

shutdown :: proc() {
	renderer.framebuffer_free(viewport_fb)

	{ 	// Clear entities world
		// TODO: Get all entities and free them in the correct way
		ecs.deinit_ecs(&entities_world)
	}

	{ 	// Gui panels
		gui_panels.scene_panel_destroy(scene_panel)
	}
}

update :: proc(dt: f64) {
	engine.camera_on_update(&camera_controller, dt)
}

render :: proc() {
	renderer.framebuffer_bind(viewport_fb)
	renderer.clear_screen({0.28, 0.28, 0.28, 1.0})

	{ 	// Render models
		for ent in ecs.get_entities_with_components(
			&entities_world,
			{^renderer.Model, engine.Transform},
		) {
			model, _ := ecs.get_component(&entities_world, ent, ^renderer.Model)
			transform, _ := ecs.get_component(&entities_world, ent, engine.Transform)

			light := renderer.Light {
				glm.vec3{0.0, 50.0, 10.0},
				glm.vec3{0.2, 0.2, 0.2},
				glm.vec3{0.9, 0.9, 0.9},
				glm.vec3{0.2, 0.2, 0.2},
			}
			renderer.renderer_draw_model(
				model^,
				&light,
				transform,
				&camera_controller._position,
				&camera_controller.view_mat,
				&camera_controller.proj_mat,
			)
		}
	}

	renderer.renderer_draw_grid(&camera_controller.view_mat, &camera_controller.proj_mat)
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
