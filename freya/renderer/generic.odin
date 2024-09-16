package renderer

import glm "core:math/linalg/glsl"

import gl "vendor:OpenGL"
import "vendor:glfw"

OpenGlCapability :: enum {
	DEPTH_TEST   = gl.DEPTH_TEST,
	STENCIL_TEST = gl.STENCIL_TEST,
	SCISSOR_TEST = gl.SCISSOR_TEST,
	CULL_FACE    = gl.CULL_FACE,
	BLEND        = gl.BLEND,
}

initialize_context :: proc() {
	gl.load_up_to(4, 6, glfw.gl_set_proc_address)
}

@(export)
clear_screen :: proc(color: glm.vec4) {
	gl.ClearColor(color.r, color.g, color.b, color.a)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)
}

@(export)
draw_grid :: proc() {
	emptyVAO: u32
	gl.GenVertexArrays(1, &emptyVAO)
	gl.BindVertexArray(emptyVAO)
	gl.DrawArrays(gl.TRIANGLE_STRIP, 0, 4)
	assert(gl.GetError() == gl.NO_ERROR, "OpenGL error")
}

on_window_resize :: proc(w, h: i32) {
	gl.Viewport(0, 0, w, h)
}

enable_capabilities :: proc(cap: []OpenGlCapability) {
	for c in cap {
		gl.Enable(u32(c))
		if c == .BLEND {
			gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
		}
	}
}

disable_capabilities :: proc(cap: []OpenGlCapability) {
	for c in cap {
		gl.Disable(u32(c))
	}
}
