package renderer

import "core:log"

Material :: struct {
	name:             string,
	diffuse_texture:  TextureHandle,
	specular_texture: TextureHandle,
	normal_texture:   TextureHandle,
	shininess:        f64,
}

material_new :: proc(
	name: string,
	diffuse, specular, normal: TextureHandle,
	shininess: f64,
) -> ^Material {
	m := new(Material)
	m.name = name
	m.diffuse_texture = diffuse
	m.specular_texture = specular
	m.normal_texture = normal
	m.shininess = shininess
	return m
}

material_free :: proc(m: ^Material) {
	free(m)
}
