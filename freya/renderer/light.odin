package renderer

// import ecs "../../freya/vendor/odin-ecs"
import glm "core:math/linalg/glsl"

import engine "../engine"

AmbientLight :: struct {
	position:   glm.vec3,
	ambient:    glm.vec3,
	diffuse:    glm.vec3,
	specular:   glm.vec3,

	//
	_model:     ^Model,
	_transform: engine.Transform,
}

// TODO: Integrate with ECS system so that lights can be added/removed/modified from the editor
ambientlight_new :: proc(
	position: glm.vec3, // world: ecs.Context,
	ambient: glm.vec3,
	diffuse: glm.vec3,
	specular: glm.vec3,
) -> ^AmbientLight {
	light := new(AmbientLight)
	light.position = position
	light.ambient = ambient
	light.diffuse = diffuse
	light.specular = specular


	model := new(Model)
	model.bone_count = 0
	model.materials = {}
	model.bone_info_map = {}

	append(&model.meshes, new_cube_mesh({}))

	light._model = model

	light._transform = engine.Transform {
		position = position,
		rotation = glm.vec3{0.0, 0.0, 0.0},
		scale    = glm.vec3{1.0, 1.0, 1.0},
	}

	light._transform.model_matrix =
		glm.mat4Translate(light._transform.position) *
		glm.mat4Rotate({1, 0, 0}, light._transform.rotation.x) *
		glm.mat4Rotate({0, 1, 0}, light._transform.rotation.y) *
		glm.mat4Rotate({0, 0, 1}, light._transform.rotation.z) *
		glm.mat4Scale(light._transform.scale)

	return light
}

ambientlight_free :: proc(light: ^AmbientLight) {
	model_free(light._model)
	free(light)
}


ambientlight_draw :: proc(self: ^AmbientLight, shader: ShaderProgram) {
	shader_set_uniform(shader, "model", &self._transform.model_matrix)
	model_draw(self._model, shader)
}
