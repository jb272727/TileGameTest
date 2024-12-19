extends Node3D

# Member variables
var tile_type: String = ""
var exists := false
var placed := false
var affiliation: String = "none" # should be unaffiliated in placed and not claimed
var buildings: Array = [] # Array to hold buildings (MeshInstance3D)
var totem: MeshInstance3D = null # Single totem (MeshInstance3D)
var tile_mesh: MeshInstance3D = null

# Function to set the tile type
func set_type(type: String) -> void:
	tile_type = type

# Function to get the tile type
func get_type() -> String:
	return tile_type

# Function to add a building
func add_building(building: MeshInstance3D) -> void:
	if building:
		buildings.append(building)
	else:
		print("Cannot add null as a building!")

# Function to retrieve all buildings
func get_buildings() -> Array:
	return buildings

# Function to set a totem
func add_totem(totem: MeshInstance3D) -> void:
	if totem:
		self.totem = totem
	else:
		print("Cannot add null as a totem!")

# Function to retrieve the totem
func get_totem() -> MeshInstance3D:
	return totem

# Function to set the tile's affiliation
func set_affiliation(color: String) -> void:
	affiliation = color

# Function to get the tile's affiliation
func get_affiliation() -> String:
	return affiliation
	
func set_tile_mesh(mesh: MeshInstance3D) -> void:
	if mesh:
		# Remove the existing mesh if one is already set
		if tile_mesh and is_ancestor_of(tile_mesh):
			remove_child(tile_mesh)
			tile_mesh.queue_free()
		
		tile_mesh = mesh
		add_child(tile_mesh) # Add the mesh as a child of this node
		tile_mesh.transform.origin = Vector3.ZERO # Ensure mesh is centered
	else:
		print("Cannot set a null mesh as the tile mesh!")

# Function to get the tile's mesh
func get_tile_mesh() -> MeshInstance3D:
	return tile_mesh
