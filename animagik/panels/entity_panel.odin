package panel

import "core:crypto"
import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"

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

		{ 	// TRANSFORM COMPONENT
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
			}
		}

		{ 	// Bone structure
			im.SeparatorText("Bone structure")
			animator, err := ecs.get_component(
				panel.entities_world,
				panel.selected_entity,
				^renderer.Animator,
			)
			if err == ecs.ECS_Error.NO_ERROR {
				root_node := (animator^).current_animation.root_node
				draw_assimp_node(&root_node)
			}
		}
	}
	im.End()


	im.Begin("Material")
	{
		model, err := ecs.get_component(
			panel.entities_world,
			panel.selected_entity,
			^renderer.Model,
		)
		if err == ecs.ECS_Error.NO_ERROR {
			for handle in model^.materials {
				material, err := renderer.resource_manager_get_material(handle)

				im.Text("Material Name : %s", strings.unsafe_string_to_cstring(material.name))
				im.Separator()

				diffuse, differr := renderer.resource_manager_get_texture(material.diffuse_texture)
				if differr == renderer.ResourceManagerError.NoError {
					im.Text("Diffuse texture")
					im.Image(
						im.TextureID(uintptr(diffuse.id)),
						{100, 100},
						{0, 1},
						{1, 0},
						{1, 1, 1, 1},
						{0, 0, 0, 0},
					)
				}

				specular, specerr := renderer.resource_manager_get_texture(
					material.specular_texture,
				)
				if specerr == renderer.ResourceManagerError.NoError {
					im.Text("Specular texture")
					im.Image(
						im.TextureID(uintptr(specular.id)),
						{100, 100},
						{0, 1},
						{1, 0},
						{1, 1, 1, 1},
						{0, 0, 0, 0},
					)
				}

				normal, normalerr := renderer.resource_manager_get_texture(material.normal_texture)
				if normalerr == renderer.ResourceManagerError.NoError {
					im.Text("Normal texture")
					im.Image(
						im.TextureID(uintptr(normal.id)),
						{100, 100},
						{0, 1},
						{1, 0},
						{1, 1, 1, 1},
						{0, 0, 0, 0},
					)
				}

				height, heighterr := renderer.resource_manager_get_texture(material.height_texture)
				if heighterr == renderer.ResourceManagerError.NoError {
					im.Text("Height texture")
					im.Image(
						im.TextureID(uintptr(height.id)),
						{100, 100},
						{0, 1},
						{1, 0},
						{1, 1, 1, 1},
						{0, 0, 0, 0},
					)
				}

				ambient, ambienterr := renderer.resource_manager_get_texture(
					material.ambient_texture,
				)
				if ambienterr == renderer.ResourceManagerError.NoError {
					im.Text("Ambient texture")
					im.Image(
						im.TextureID(uintptr(ambient.id)),
						{100, 100},
						{0, 1},
						{1, 0},
						{1, 1, 1, 1},
						{0, 0, 0, 0},
					)
				}

				im.Text("Material - shininess : %f", material.shininess)

				im.Separator()
			}
		}
	}
	im.End()
}

@(private)
add_model_panel :: proc(panel: ^ScenePanel) {
	name_buffer: []byte = make([]byte, 20)
	im.InputText("Entity Name", cstring(&name_buffer[0]), 20)

	object_path := file_selector_panel(panel.model_file_selector)

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
			name_buffer: [5]u8
			crypto.rand_bytes(name_buffer[:])

			name = fmt.tprintf(
				"%02x%02x%02x%02x%02x",
				name_buffer[0],
				name_buffer[1],
				name_buffer[2],
				name_buffer[3],
				name_buffer[4],
			)
			ecs.add_component(panel.entities_world, ent, engine.Name(name))

		} else {
			ecs.add_component(panel.entities_world, ent, engine.Name(name))
		}
		file_selector_reset(panel.model_file_selector)
		show_add_entity_panel = false
	}
}

@(private)
draw_assimp_node :: proc(node: ^renderer.AssimpNodeData) {
	if im.TreeNode(strings.unsafe_string_to_cstring(node.name)) {
		im.Text("Children Count: %d", node.children_count)


		for &child in node.children {
			draw_assimp_node(&child)
		}

		im.TreePop()
	}
}
