package renderer

import "core:crypto/hash"
import "core:log"

// @(private) // TODO: Make this private
RESOURCE_MANAGER: ^ResourceManager = nil

Handle :: #type string
TextureHandle :: distinct Handle

ResourceManager :: struct {
	textures: map[TextureHandle]^Texture,
}

resource_manager_get :: proc {
	resource_manager_get_texture,
}

@(export)
resource_manager_get_texture :: proc(handle: TextureHandle) -> ^Texture {
	texture, ok := RESOURCE_MANAGER.textures[handle]
	if !ok {
		log.errorf("Texture not found: {}", handle)
		return nil // NOTE: Return a default texture ?
	}
	return texture
}

resource_manager_add :: proc {
	resource_manager_add_texture,
}

// Its fine to use SHA1 here since we are not using it for security purposes
HASH_ALGORITHM :: hash.Algorithm.Insecure_SHA1

@(export)
resource_manager_add_texture :: proc(path: string, type: TextureType) -> TextureHandle {
	// digest := hash.hash(hash.Algorithm.Insecure_SHA1, path)
	// defer delete(digest)
	digest := path

	if _, ok := RESOURCE_MANAGER.textures[TextureHandle(digest)]; ok {
		log.debugf("Texture already loaded: {}", path)
		return TextureHandle(digest)
	}

	texture: ^Texture = texture_new(path, type)
	RESOURCE_MANAGER.textures[TextureHandle(digest)] = texture

	return TextureHandle(digest)
}

resource_manager_delete :: proc {
	resource_manager_delete_texture,
}

@(export)
resource_manager_delete_texture :: proc(handle: TextureHandle) {
	texture, ok := RESOURCE_MANAGER.textures[handle]
	if !ok {
		log.errorf("Shader not found: {}", handle)
		return
	}

	texture_free(texture)
	delete_key(&RESOURCE_MANAGER.textures, handle)
}

resource_manager_new :: proc() {
	if RESOURCE_MANAGER != nil {
		log.panic("Can't have more than one ResourceManager instance!")
	}

	RESOURCE_MANAGER = new(ResourceManager)
	RESOURCE_MANAGER.textures = make(map[TextureHandle]^Texture)
}

resource_manager_free :: proc() {
	if RESOURCE_MANAGER == nil {
		log.panic("ResourceManager instance is nil!")
	}

	delete(RESOURCE_MANAGER.textures)
	free(RESOURCE_MANAGER)

	RESOURCE_MANAGER = nil
}

resource_manager_get_textures :: proc() -> map[TextureHandle]^Texture {
	return RESOURCE_MANAGER.textures
}
