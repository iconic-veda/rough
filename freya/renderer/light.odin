package renderer

import glm "core:math/linalg/glsl"

Light :: struct {
	position: glm.vec3,
	ambient:  glm.vec3,
	diffuse:  glm.vec3,
	specular: glm.vec3,
}
