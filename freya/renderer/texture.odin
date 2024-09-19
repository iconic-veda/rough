package renderer

import "core:log"
import "core:strings"

import gl "vendor:OpenGL"
import stb_img "vendor:stb/image"

Texture :: struct {
	id:   u32,
	type: TextureType,
	path: string,
}

TextureType :: enum {
	Diffuse,
	Specular,
}

@(export)
texture_new :: proc(file_path: string, type: TextureType) -> ^Texture {
	filename := strings.unsafe_string_to_cstring(file_path)

	width, height, channels: i32
	stb_img.set_flip_vertically_on_load(1)
	data: [^]byte = stb_img.load(filename, &width, &height, &channels, 0)

	if data == nil {
		log.panic("Failed to load texture")
	}
	defer stb_img.image_free(data)

	format: i32
	switch channels {
	case 1:
		format = gl.RED
	case 3:
		format = gl.RGB
	case 4:
		format = gl.RGBA
	}

	texture: u32 = 0
	gl.GenTextures(1, &texture)
	gl.BindTexture(gl.TEXTURE_2D, texture)

	gl.TexImage2D(gl.TEXTURE_2D, 0, format, width, height, 0, u32(format), gl.UNSIGNED_BYTE, data)
	gl.GenerateMipmap(gl.TEXTURE_2D)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

	tex := new(Texture)
	tex.id = texture
	tex.type = type
	tex.path = file_path[:]

	return tex
}

@(export)
texture_free :: proc(texture: ^Texture) {
	gl.DeleteTextures(1, &texture.id)
	free(texture)
}
