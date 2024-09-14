package engine

import glm "core:math/linalg/glsl"

PerspectiveCamera :: struct {
	view_mat: glm.mat4,
	proj_mat: glm.mat4,

	// Camera vectors
	up:       glm.vec3,
	eye:      glm.vec3,
	center:   glm.vec3,
}

camera_new_perspective :: proc(fov, aspect_ratio, near, far: f32) -> PerspectiveCamera {
	camera := PerspectiveCamera{}
	camera_set_projection(&camera, fov, aspect_ratio, near, far)
	camera_calculate_view_matrix(&camera)
	return camera
}

camera_set_projection :: proc(camera: ^PerspectiveCamera, fov, aspect_ratio, near, far: f32) {
	camera.proj_mat = glm.mat4Perspective(glm.radians(fov), aspect_ratio, near, far)
}

camera_calculate_view_matrix :: proc(camera: ^PerspectiveCamera) {
	camera.view_mat = glm.mat4LookAt(camera.eye, camera.center, camera.up)
}
