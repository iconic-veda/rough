package panel

import "core:fmt"
import "core:math"
import "core:strings"

import engine "../../freya/engine"

import ecs "../../freya/vendor/YggECS"
import im "../../freya/vendor/odin-imgui"

import glm "core:math/linalg/glsl"


ScenePanel :: struct {
	entities_world: ^ecs.World,
}

scene_panel_new :: proc(entities_world: ^ecs.World) -> ^ScenePanel {
	panel := new(ScenePanel)

	panel.entities_world = entities_world

	return panel
}

scene_panel_destroy :: proc(panel: ^ScenePanel) {
	free(panel)
}

scene_panel_render :: proc(panel: ^ScenePanel) {
	im.Begin("Entities")
	if im.TreeNode("Entities") {
		for _, archetype in panel.entities_world.archetypes {
			for entity_index, index in archetype.entities {
				entity := archetype.entities[index]

				entity_index := fmt.tprintf("Row: %d", entity_index)
				im.Text(strings.unsafe_string_to_cstring(entity_index))

				if ecs.has_component_type(panel.entities_world, entity, engine.Transform) {
					transform := ecs.get_component(
						panel.entities_world,
						entity,
						engine.Transform,
						engine.Transform,
					)

					// Position controls
					im.Text("Position:")
					pos_changed := false
					pos_changed |= im.DragFloat3(
						"Pos",
						&transform.position,
						0.1,
						-math.F32_MAX,
						math.F32_MAX,
					)

					// Rotation controls
					im.Text("Rotation:")
					pos_changed |= im.DragFloat3(
						"Rot",
						&transform.rotation,
						0.1,
						-math.PI,
						math.PI,
					)

					// Scale controls
					im.Text("Scale:")
					pos_changed |= im.DragFloat3("Scale", &transform.scale, 0.01, 0, 10)

					if pos_changed {
						transform.model_matrix =
							glm.mat4Translate(transform.position) *
							glm.mat4Rotate({1, 0, 0}, transform.rotation.x) *
							glm.mat4Rotate({0, 1, 0}, transform.rotation.y) *
							glm.mat4Rotate({0, 0, 1}, transform.rotation.z) *
							glm.mat4Scale(transform.scale)
						ecs.remove_component(panel.entities_world, entity, engine.Transform)
						ecs.add_component(panel.entities_world, entity, transform)
					}
				}

				// List component IDs
				for component_id in archetype.component_ids {
					component_info, ok := panel.entities_world.component_info[component_id]
					if ok {
						component_id := fmt.tprintf("Component: %v", component_info.type_info.id)
						im.Text(strings.unsafe_string_to_cstring(component_id))
					}
				}
			}
		}
		im.TreePop()
	}
	im.End()
}
