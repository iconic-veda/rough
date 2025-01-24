package engine

import im "../vendor/odin-imgui"
import "../vendor/odin-imgui/imgui_impl_glfw"
import "../vendor/odin-imgui/imgui_impl_opengl3"

DISABLE_DOCKING :: #config(DISABLE_DOCKING, false)

init_imgui :: proc() {
	im.CHECKVERSION()
	im.CreateContext()
	imgui_io := im.GetIO()
	imgui_io.ConfigFlags += {.NavEnableKeyboard}
	when !DISABLE_DOCKING {
		imgui_io.ConfigFlags += {.DockingEnable}

		style := im.GetStyle()
		style.WindowRounding = 0
		style.Colors[im.Col.WindowBg].w = 1
	}

	// im.StyleColorsDark()
	// setup_custom_theme()
	im.StyleColorsLight()

	imgui_impl_glfw.InitForOpenGL(WINDOW.glfw_window, true)
	imgui_impl_opengl3.Init()
}

shutdown_imgui :: proc() {
	imgui_impl_opengl3.Shutdown()
	imgui_impl_glfw.Shutdown()
	im.DestroyContext()
}

begin_imgui :: proc() {
	imgui_impl_opengl3.NewFrame()
	imgui_impl_glfw.NewFrame()
	im.NewFrame()
}

end_imgui :: proc() {
	im.Render()
	imgui_impl_opengl3.RenderDrawData(im.GetDrawData())
}


setup_custom_theme :: proc() {
	style := im.GetStyle()
	style.GrabRounding = 4.0
	colors := style.Colors

	style.WindowPadding = im.Vec2{0, 0}
	style.WindowRounding = 5.0
	style.FramePadding = im.Vec2{5, 5}
	style.FrameRounding = 4.0
	style.ItemSpacing = im.Vec2{12, 8}
	style.ItemInnerSpacing = im.Vec2{8, 6}
	style.IndentSpacing = 25.0
	style.ScrollbarSize = 15.0
	style.ScrollbarRounding = 9.0
	style.GrabMinSize = 5.0
	style.GrabRounding = 3.0

	colors[im.Col.Text] = im.Vec4{0.80, 0.80, 0.83, 1.00}
	colors[im.Col.TextDisabled] = im.Vec4{0.24, 0.23, 0.29, 1.00}
	colors[im.Col.WindowBg] = im.Vec4{0.06, 0.05, 0.07, 1.00}
	colors[im.Col.ChildBg] = im.Vec4{0.07, 0.07, 0.09, 1.00}
	colors[im.Col.PopupBg] = im.Vec4{0.07, 0.07, 0.09, 1.00}
	colors[im.Col.Border] = im.Vec4{0.80, 0.80, 0.83, 0.88}
	colors[im.Col.BorderShadow] = im.Vec4{0.92, 0.91, 0.88, 0.00}
	colors[im.Col.FrameBg] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.FrameBgHovered] = im.Vec4{0.24, 0.23, 0.29, 1.00}
	colors[im.Col.FrameBgActive] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.TitleBg] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.TitleBgCollapsed] = im.Vec4{1.00, 0.98, 0.95, 0.75}
	colors[im.Col.TitleBgActive] = im.Vec4{0.07, 0.07, 0.09, 1.00}
	colors[im.Col.MenuBarBg] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.ScrollbarBg] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.ScrollbarGrab] = im.Vec4{0.80, 0.80, 0.83, 0.31}
	colors[im.Col.ScrollbarGrabHovered] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.ScrollbarGrabActive] = im.Vec4{0.06, 0.05, 0.07, 1.00}
	// colors[im.Col.ComboBg] = im.Vec4{0.19, 0.18, 0.21, 1.00}
	colors[im.Col.CheckMark] = im.Vec4{0.80, 0.80, 0.83, 0.31}
	colors[im.Col.SliderGrab] = im.Vec4{0.80, 0.80, 0.83, 0.31}
	colors[im.Col.SliderGrabActive] = im.Vec4{0.06, 0.05, 0.07, 1.00}
	colors[im.Col.Button] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.ButtonHovered] = im.Vec4{0.24, 0.23, 0.29, 1.00}
	colors[im.Col.ButtonActive] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.Header] = im.Vec4{0.10, 0.09, 0.12, 1.00}
	colors[im.Col.HeaderHovered] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.HeaderActive] = im.Vec4{0.06, 0.05, 0.07, 1.00}
	// colors[im.Col.Column] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	// colors[im.Col.ColumnHovered] = im.Vec4{0.24, 0.23, 0.29, 1.00}
	// colors[im.Col.ColumnActive] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.ResizeGrip] = im.Vec4{0.00, 0.00, 0.00, 0.00}
	colors[im.Col.ResizeGripHovered] = im.Vec4{0.56, 0.56, 0.58, 1.00}
	colors[im.Col.ResizeGripActive] = im.Vec4{0.06, 0.05, 0.07, 1.00}
	// colors[im.Col.CloseButton] = im.Vec4{0.40, 0.39, 0.38, 0.16}
	// colors[im.Col.CloseButtonHovered] = im.Vec4{0.40, 0.39, 0.38, 0.39}
	// colors[im.Col.CloseButtonActive] = im.Vec4{0.40, 0.39, 0.38, 1.00}
	colors[im.Col.PlotLines] = im.Vec4{0.40, 0.39, 0.38, 0.63}
	colors[im.Col.PlotLinesHovered] = im.Vec4{0.25, 1.00, 0.00, 1.00}
	colors[im.Col.PlotHistogram] = im.Vec4{0.40, 0.39, 0.38, 0.63}
	colors[im.Col.PlotHistogramHovered] = im.Vec4{0.25, 1.00, 0.00, 1.00}
	colors[im.Col.TextSelectedBg] = im.Vec4{0.25, 1.00, 0.00, 0.43}
	// colors[im.Col.ModalWindowDarkening] = im.Vec4{1.00, 0.98, 0.95, 0.73}
}
