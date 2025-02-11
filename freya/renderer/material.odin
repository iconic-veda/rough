package renderer

import "core:log"

Material :: struct {
	name:             string,
	diffuse_texture:  TextureHandle,
	specular_texture: TextureHandle,
	height_texture:   TextureHandle,
	ambient_texture:  TextureHandle,
	shininess:        f64,
}

material_new :: proc(
	name: string,
	diffuse, specular, height, ambient: TextureHandle,
	shininess: f64,
) -> ^Material {
	m := new(Material)
	m.name = name
	m.diffuse_texture = diffuse
	m.specular_texture = specular
	m.height_texture = height
	m.ambient_texture = ambient
	m.shininess = shininess
	return m
}

material_free :: proc(m: ^Material) {
	free(m)
}
