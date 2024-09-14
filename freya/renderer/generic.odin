package renderer

import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:glfw"

OpenGlCapability :: enum {
	DEPTH_TEST   = gl.DEPTH_TEST,
	STENCIL_TEST = gl.STENCIL_TEST,
	SCISSOR_TEST = gl.SCISSOR_TEST,
	CULL_FACE    = gl.CULL_FACE,
}

initialize_context :: proc() {
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
}

@(export)
clear_screen :: proc(color: glm.vec4) {
	gl.ClearColor(color.r, color.g, color.b, color.a)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

on_window_resize :: proc(w, h: i32) {
	gl.Viewport(0, 0, w, h)
}

enable_capabilities :: proc(cap: []OpenGlCapability) {
	for c in cap {
		gl.Enable(u32(c))
	}
}

disable_capabilities :: proc(cap: []OpenGlCapability) {
	for c in cap {
		gl.Disable(u32(c))
	}
}
