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
	selected_entity: ecs.Entity,
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
	im.Begin("Entities")
	selected: bool = false
	for ent, idx in panel.entities_world.entities.entities {
		if !ent.is_valid {
			continue
		}

		ent := ent.entity
		name, err := ecs.get_component(panel.entities_world, ent, engine.Name)
		if err == ecs.ECS_Error.ENTITY_DOES_NOT_HAVE_THIS_COMPONENT {
			continue
		}

		selected = panel.selected_entity == ent
		if im.Selectable(strings.unsafe_string_to_cstring(name^), selected) {
			panel.selected_entity = ent
		}
	}
	im.End()

	im.Begin("Selected entity")
	name, err := ecs.get_component(panel.entities_world, panel.selected_entity, engine.Name)
	if err != ecs.ECS_Error.ENTITY_DOES_NOT_HAVE_THIS_COMPONENT {
		// new_name: string = "dsadsa;kd;lsak;l"
		// im.InputText("Name", strings.unsafe_string_to_cstring(new_name), len(new_name))

		// TODO: Change font size/style(bold)
		im.Text("Entity name: %s", strings.unsafe_string_to_cstring(name^))

		im.SeparatorText("Transform")
		transform, err := ecs.get_component(
			panel.entities_world,
			panel.selected_entity,
			engine.Transform,
		)
		if err == ecs.ECS_Error.NO_ERROR {
			{ 	// Transform
				im.Text("Position:")
				changed := false
				changed |= im.DragFloat3(
					"Pos",
					&transform.position,
					0.1,
					-math.F32_MAX,
					math.F32_MAX,
				)

				im.Text("Rotation:")
				changed |= im.DragFloat3("Rot", &transform.rotation, 0.1, -math.PI, math.PI)

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
			}

			{ 	// Texture

			}
		}
	}
	im.Separator()

	im.End()
}
