package engine

import "vendor:glfw"

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
		imgui_io.ConfigFlags += {.DockingEnable, .ViewportsEnable}

		style := im.GetStyle()
		style.WindowRounding = 0
		style.Colors[im.Col.WindowBg].w = 1
	}

	// im.StyleColorsDark()
	// im.StyleColorsLight()
	setup_custom_theme()

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

	backup_current_window := glfw.GetCurrentContext()
	im.UpdatePlatformWindows()
	im.RenderPlatformWindowsDefault()
	glfw.MakeContextCurrent(backup_current_window)

}


setup_custom_theme :: proc() {
	style := im.GetStyle()

	style.Colors[im.Col.Text] = im.Vec4{0.90, 0.89, 0.88, 1.00} // Latte
	style.Colors[im.Col.TextDisabled] = im.Vec4{0.60, 0.56, 0.52, 1.00} // Surace2
	style.Colors[im.Col.WindowBg] = im.Vec4{0.17, 0.14, 0.20, 1.00} // Base
	style.Colors[im.Col.ChildBg] = im.Vec4{0.18, 0.16, 0.22, 1.00} // Mantle
	style.Colors[im.Col.PopupBg] = im.Vec4{0.17, 0.14, 0.20, 1.00} // Base
	style.Colors[im.Col.Border] = im.Vec4{0.27, 0.23, 0.29, 1.00} // Overlay0
	style.Colors[im.Col.BorderShadow] = im.Vec4{0.00, 0.00, 0.00, 0.00}
	style.Colors[im.Col.FrameBg] = im.Vec4{0.21, 0.18, 0.25, 1.00} // Crust
	style.Colors[im.Col.FrameBgHovered] = im.Vec4{0.24, 0.20, 0.29, 1.00} // Overlay1
	style.Colors[im.Col.FrameBgActive] = im.Vec4{0.26, 0.22, 0.31, 1.00} // Overlay2
	style.Colors[im.Col.TitleBg] = im.Vec4{0.14, 0.12, 0.18, 1.00} // Mantle
	style.Colors[im.Col.TitleBgActive] = im.Vec4{0.17, 0.15, 0.21, 1.00} // Mantle
	style.Colors[im.Col.TitleBgCollapsed] = im.Vec4{0.14, 0.12, 0.18, 1.00} // Mantle
	style.Colors[im.Col.MenuBarBg] = im.Vec4{0.17, 0.15, 0.22, 1.00} // Base
	style.Colors[im.Col.ScrollbarBg] = im.Vec4{0.17, 0.14, 0.20, 1.00} // Base
	style.Colors[im.Col.ScrollbarGrab] = im.Vec4{0.21, 0.18, 0.25, 1.00} // Crust
	style.Colors[im.Col.ScrollbarGrabHovered] = im.Vec4{0.24, 0.20, 0.29, 1.00} // Overlay1
	style.Colors[im.Col.ScrollbarGrabActive] = im.Vec4{0.26, 0.22, 0.31, 1.00} // Overlay2
	style.Colors[im.Col.CheckMark] = im.Vec4{0.95, 0.66, 0.47, 1.00} // Peach
	style.Colors[im.Col.SliderGrab] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.SliderGrabActive] = im.Vec4{0.89, 0.54, 0.79, 1.00} // Pink
	style.Colors[im.Col.Button] = im.Vec4{0.65, 0.34, 0.46, 1.00} // Maroon
	style.Colors[im.Col.ButtonHovered] = im.Vec4{0.71, 0.40, 0.52, 1.00} // Red
	style.Colors[im.Col.ButtonActive] = im.Vec4{0.76, 0.46, 0.58, 1.00} // Pink
	style.Colors[im.Col.Header] = im.Vec4{0.65, 0.34, 0.46, 1.00} // Maroon
	style.Colors[im.Col.HeaderHovered] = im.Vec4{0.71, 0.40, 0.52, 1.00} // Red
	style.Colors[im.Col.HeaderActive] = im.Vec4{0.76, 0.46, 0.58, 1.00} // Pink
	style.Colors[im.Col.Separator] = im.Vec4{0.27, 0.23, 0.29, 1.00} // Overlay0
	style.Colors[im.Col.SeparatorHovered] = im.Vec4{0.95, 0.66, 0.47, 1.00} // Peach
	style.Colors[im.Col.SeparatorActive] = im.Vec4{0.95, 0.66, 0.47, 1.00} // Peach
	style.Colors[im.Col.ResizeGrip] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.ResizeGripHovered] = im.Vec4{0.89, 0.54, 0.79, 1.00} // Pink
	style.Colors[im.Col.ResizeGripActive] = im.Vec4{0.92, 0.61, 0.85, 1.00} // Mauve
	style.Colors[im.Col.Tab] = im.Vec4{0.21, 0.18, 0.25, 1.00} // Crust
	style.Colors[im.Col.TabHovered] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.TabSelected] = im.Vec4{0.76, 0.46, 0.58, 1.00} // Pink
	style.Colors[im.Col.TabDimmed] = im.Vec4{0.18, 0.16, 0.22, 1.00} // Mantle
	style.Colors[im.Col.TabHovered] = im.Vec4{0.21, 0.18, 0.25, 1.00} // Crust
	style.Colors[im.Col.DockingPreview] = im.Vec4{0.95, 0.66, 0.47, 0.70} // Peach
	style.Colors[im.Col.DockingEmptyBg] = im.Vec4{0.12, 0.12, 0.12, 1.00} // Base
	style.Colors[im.Col.PlotLines] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.PlotLinesHovered] = im.Vec4{0.89, 0.54, 0.79, 1.00} // Pink
	style.Colors[im.Col.PlotHistogram] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.PlotHistogramHovered] = im.Vec4{0.89, 0.54, 0.79, 1.00} // Pink
	style.Colors[im.Col.TableHeaderBg] = im.Vec4{0.19, 0.19, 0.20, 1.00} // Mantle
	style.Colors[im.Col.TableBorderStrong] = im.Vec4{0.27, 0.23, 0.29, 1.00} // Overlay0
	style.Colors[im.Col.TableBorderLight] = im.Vec4{0.23, 0.23, 0.25, 1.00} // Surace2
	style.Colors[im.Col.TableRowBg] = im.Vec4{0.00, 0.00, 0.00, 0.00}
	style.Colors[im.Col.TableRowBgAlt] = im.Vec4{1.00, 1.00, 1.00, 0.06} // Surace0
	style.Colors[im.Col.TextSelectedBg] = im.Vec4{0.82, 0.61, 0.85, 0.35} // Lavender
	style.Colors[im.Col.DragDropTarget] = im.Vec4{0.95, 0.66, 0.47, 0.90} // Peach
	style.Colors[im.Col.NavHighlight] = im.Vec4{0.82, 0.61, 0.85, 1.00} // Lavender
	style.Colors[im.Col.NavWindowingHighlight] = im.Vec4{1.00, 1.00, 1.00, 0.70}
	style.Colors[im.Col.NavWindowingDimBg] = im.Vec4{0.80, 0.80, 0.80, 0.20}
	style.Colors[im.Col.ModalWindowDimBg] = im.Vec4{0.80, 0.80, 0.80, 0.35}

	// Style adjustments
	style.WindowRounding = 8.0
	style.FrameRounding = 4.0
	style.ScrollbarRounding = 4.0
	style.GrabRounding = 4.0
	style.ChildRounding = 4.0

	style.WindowTitleAlign = im.Vec2{0.50, 0.50}
	style.WindowPadding = im.Vec2{8.0, 8.0}
	style.FramePadding = im.Vec2{5.0, 4.0}
	style.ItemSpacing = im.Vec2{6.0, 6.0}
	style.ItemInnerSpacing = im.Vec2{6.0, 6.0}
	style.IndentSpacing = 22.0

	style.ScrollbarSize = 14.0
	style.GrabMinSize = 10.0

	style.AntiAliasedLines = true
	style.AntiAliasedFill = true
}
