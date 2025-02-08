package panel

import "core:math"
import "core:os"
import "core:strings"

import "core:fmt"

import engine "../../freya/engine"
import renderer "../../freya/renderer"

import ecs "../../freya/vendor/odin-ecs"

import im "../../freya/vendor/odin-imgui"

import glm "core:math/linalg/glsl"


show_add_entity_panel: bool = false

ScenePanel :: struct {
	entities_world:      ^ecs.Context,
	selected_entity:     ecs.Entity,
	model_file_selector: ^FileSelector,
}

scene_panel_new :: proc(entities_world: ^ecs.Context) -> ^ScenePanel {
	panel := new(ScenePanel)
	panel.entities_world = entities_world
	panel.model_file_selector = file_selector_new()
	return panel
}

scene_panel_destroy :: proc(panel: ^ScenePanel) {
	free(panel)
}

scene_panel_render :: proc(panel: ^ScenePanel) {
	im.Begin("Entities")

	if im.Button("Add entity") {
		show_add_entity_panel = true
	}

	if show_add_entity_panel {
		im.Begin("Add Entity")
		add_model_panel(panel)
		im.End()
	}

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

@(private)
add_model_panel :: proc(panel: ^ScenePanel) {
	name_buffer: []byte = make([]byte, 20)
	im.InputText("Entity Name", cstring(&name_buffer[0]), 20)

	if im.Button("Select Model File") {
		panel.model_file_selector.show_file_selector = true
	}

	if panel.model_file_selector.show_file_selector {
		object_path: string
		path := file_selector_panel(panel.model_file_selector)
		if strings.ends_with(path, ".obj") {
			object_path = file_selector_panel(panel.model_file_selector)
		} else if strings.ends_with(path, ".dae") {
			object_path = file_selector_panel(panel.model_file_selector)
		} else if strings.ends_with(path, ".fbx") {
			object_path = file_selector_panel(panel.model_file_selector)
		} else if strings.ends_with(path, ".gltf") {
			object_path = file_selector_panel(panel.model_file_selector)
		} else if strings.ends_with(path, ".glb") {
			object_path = file_selector_panel(panel.model_file_selector)
		}

		if object_path != "" {
			model_component := renderer.model_new(object_path)
			if model_component == nil {
				file_selector_reset(panel.model_file_selector)
				return
			}
			ent := ecs.create_entity(panel.entities_world)
			ecs.add_component(panel.entities_world, ent, model_component)
			ecs.add_component(
				panel.entities_world,
				ent,
				engine.Transform {
					glm.vec3{0.0, 0.0, 0.0},
					glm.vec3{0.0, 0.0, 0.0},
					glm.vec3{1.0, 1.0, 1.0},
					glm.mat4Translate({0.0, 0.0, 0.0}),
				},
			)

			null_pos := 0
			for null_pos < 20 && name_buffer[null_pos] != 0 {
				null_pos += 1
			}

			name := string(name_buffer[:null_pos])
			if name == "" {
				ecs.add_component(panel.entities_world, ent, engine.Name("Test entity"))
			} else {
				ecs.add_component(panel.entities_world, ent, engine.Name(name_buffer[:]))
			}
			file_selector_reset(panel.model_file_selector)
			show_add_entity_panel = false
		}
	}
}
