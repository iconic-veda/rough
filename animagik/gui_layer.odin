package animagik

import freya "../freya"
import engine "../freya/engine"
import renderer "../freya/renderer"

import im "../freya/vendor/odin-imgui"

ASPECT_RATIO: f32 = 800.0 / 600.0

camera_controller: engine.OpenGLCameraController
shader: renderer.ShaderProgram
grid_shader: renderer.ShaderProgram
viewport_fb: ^renderer.FrameBuffer

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
}

shutdown :: proc() {
	renderer.shader_delete(shader)
	renderer.shader_delete(grid_shader)

	renderer.framebuffer_free(viewport_fb)
}

update :: proc(dt: f64) {
	{
		if engine.is_button_pressed(engine.MouseButton.ButtonMiddle) {
			engine.camera_on_update(&camera_controller, dt)
		}
	}
}

render :: proc() {
	renderer.framebuffer_bind(viewport_fb)
	renderer.clear_screen({0.1, 0.1, 0.1, 1.0})
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

	im.Begin("Scene", nil, window_flags)
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
