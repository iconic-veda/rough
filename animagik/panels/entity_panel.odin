package panel

import "core:math"
import "core:strings"

import engine "../../freya/engine"
// import renderer "../../freya/renderer"

import ecs "../../freya/vendor/odin-ecs"

import im "../../freya/vendor/odin-imgui"

import glm "core:math/linalg/glsl"


ScenePanel :: struct {
	entities_world:  ^ecs.Context,
	selected_entity: ^ecs.Entity,
}

scene_panel_new :: proc(entities_world: ^ecs.Context) -> ^ScenePanel {
	panel := new(ScenePanel)
	panel.entities_world = entities_world
	return panel
}

scene_panel_destroy :: proc(panel: ^ScenePanel) {
	free(panel)
}

scene_panel_render :: proc(panel: ^ScenePanel) {
	im.Begin("Default entities")
	im.End()

	im.Begin("Entities")

	for ent in panel.entities_world.entities.entities {
		if !ent.is_valid {
			continue
		}

		ent := ent.entity
		name, err := ecs.get_component(panel.entities_world, ent, engine.Name)
		if err == ecs.ECS_Error.ENTITY_DOES_NOT_HAVE_THIS_COMPONENT {
			continue
		}

		if im.TreeNode(strings.unsafe_string_to_cstring(name^)) {
			transform, err := ecs.get_component(panel.entities_world, ent, engine.Transform)
			if err == ecs.ECS_Error.ENTITY_DOES_NOT_HAVE_THIS_COMPONENT {
				continue
			}
			if im.TreeNode("Transform") {
				// Position controls
				im.Text("Position:")
				changed := false
				changed |= im.DragFloat3(
					"Pos",
					&transform.position,
					0.1,
					-math.F32_MAX,
					math.F32_MAX,
				)

				// Rotation controls
				im.Text("Rotation:")
				changed |= im.DragFloat3("Rot", &transform.rotation, 0.1, -math.PI, math.PI)

				// Scale controls
				im.Text("Scale:")
				changed |= im.DragFloat3("Scale", &transform.scale, 0.01, 0, 10)

				if changed {
					transform.model_matrix =
						glm.mat4Translate(transform.position) *
						glm.mat4Rotate({1, 0, 0}, transform.rotation.x) *
						glm.mat4Rotate({0, 1, 0}, transform.rotation.y) *
						glm.mat4Rotate({0, 0, 1}, transform.rotation.z) *
						glm.mat4Scale(transform.scale)
				}
				im.TreePop()
			}
			im.TreePop()
		}
	}
	im.End()
}
