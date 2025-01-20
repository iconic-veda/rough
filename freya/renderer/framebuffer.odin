package renderer

import gl "vendor:OpenGL"

FrameBuffer :: struct {
	id:            u32,
	attachments:   []FrameBufferAttachment,
	width, height: i32,
}

FrameBufferAttachment :: enum {
	Color,
	DepthStencil,
}

framebuffer_new :: proc(width, height: i32, types: []FrameBufferAttachment) -> ^FrameBuffer {
	fbo := new(FrameBuffer)

	fbo.width = width
	fbo.height = height

	gl.CreateFramebuffers(1, &fbo.id)
	gl.BindFramebuffer(gl.FRAMEBUFFER, fbo.id)

	_framebuffer_add_attachment(fbo, types)

	if gl.CheckFramebufferStatus(gl.FRAMEBUFFER) != gl.FRAMEBUFFER_COMPLETE {
		panic("Framebuffer is not complete")
	}
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
	return fbo
}


framebuffer_bind :: proc(fbo: ^FrameBuffer) {
	gl.BindFramebuffer(gl.FRAMEBUFFER, fbo.id)
}

framebuffer_unbind :: proc() {
	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)
}

framebuffer_delete :: proc(fbo: ^FrameBuffer) {
	gl.DeleteFramebuffers(1, &fbo.id)
}

_framebuffer_add_attachment :: proc(fbo: ^FrameBuffer, types: []FrameBufferAttachment) {
	for t in types {
		switch t {
		case FrameBufferAttachment.Color:
			tex := texture_new_empty(fbo.width, fbo.height)
			gl.FramebufferTexture2D(gl.FRAMEBUFFER, gl.COLOR_ATTACHMENT0, gl.TEXTURE_2D, tex.id, 0)
		case FrameBufferAttachment.DepthStencil:
			rbo: u32 = 0
			gl.GenRenderbuffers(1, &rbo)
			gl.BindRenderbuffer(gl.RENDERBUFFER, rbo)
			gl.RenderbufferStorage(gl.RENDERBUFFER, gl.DEPTH24_STENCIL8, fbo.width, fbo.height)
			gl.BindRenderbuffer(gl.RENDERBUFFER, 0)
			gl.FramebufferRenderbuffer(
				gl.FRAMEBUFFER,
				gl.DEPTH_STENCIL_ATTACHMENT,
				gl.RENDERBUFFER,
				rbo,
			)
		}
	}
}
