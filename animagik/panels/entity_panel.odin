package panel

import "core:fmt"
import "core:strings"

import ecs "../../freya/vendor/YggECS"
import im "../../freya/vendor/odin-imgui"

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
	im.Begin("Scene panel")

	if im.TreeNode("Entities") {
		for _, archetype in panel.entities_world.archetypes {
			archetype_name := fmt.tprintf("Archetype 0x%x", archetype.id)
			if im.TreeNode(strings.unsafe_string_to_cstring(archetype_name)) {
				for entity_index, entity in archetype.entities {
					entity_name := fmt.tprintf("Entity %d", entity)
					if im.TreeNode(strings.unsafe_string_to_cstring(entity_name)) {
						entity_index := fmt.tprintf("Row: %d", entity_index)
						im.Text(strings.unsafe_string_to_cstring(entity_index))
						for component_id in archetype.component_ids {
							component_info, ok := panel.entities_world.component_info[component_id]
							if ok {
								component_id := fmt.tprintf(
									"Component: %v",
									component_info.type_info.id,
								)
								im.Text(strings.unsafe_string_to_cstring(component_id))
							}
						}
						im.TreePop()
					}
				}
				im.TreePop()
			}
		}
		im.TreePop()
	}

	im.End()
}
