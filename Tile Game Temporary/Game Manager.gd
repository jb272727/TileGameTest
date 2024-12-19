@tool
extends Node3D

@export var max_distance: float = 1000.0 # Maximum raycast distance
var hovered_object: Node3D = null
var game_board := []
const TILE_SPACING: float = 0.075 # 0.075 meters apart
@onready var board_node := $Board

@export var board_shape: String = "5x5"

func _ready():
	generate()

@export var start: bool = false : set = set_start
func set_start(val: bool) -> void:
	clear()
	generate()


func clear():
	for child in board_node.get_children():
		var kids : Array = child.get_children()
		if kids:
			for kid in kids:
				var staticBodies : Array = kid.get_children()
				if staticBodies:
					for body in staticBodies:
						var collisionBodies : Array = body.get_children()
						for collider in collisionBodies:
							collider.queue_free()
						body.queue_free()
				kid.queue_free()
		child.queue_free()

func generate():
	print("generating...")
	init_board(board_shape)
	for i in range(6):
		for j in range(6):
			print(str(i*6 +j) + " " + str(game_board[i][j].exists))
			
	for row in range(6): # 6 rows
		for col in range(6): # 6 columns
			var index = row * 6 + col # Linear index for a 6x6 grid
			var tile = game_board[row][col]
			
			var tile_pos_node = Node3D.new()
			tile_pos_node.name = "TilePos_%d" % index
			
			# Calculate position offset from the Board node (top-left)
			var x_offset = -col * TILE_SPACING
			var z_offset = row * TILE_SPACING
			var tile_position = Vector3(x_offset, 0, z_offset)
			tile_pos_node.transform.origin = tile_position

			board_node.add_child(tile_pos_node)
			
			# If the tile should exist, instantiate it and add it to the position node
			if tile.exists:
				tile.transform.origin = Vector3(0, 0, 0) # Center the tile on the position node
				
				var static_body = StaticBody3D.new()
				static_body.name = "StaticBody_Tile_%d" % index
				
				var collision_shape = CollisionShape3D.new()
				var box_shape = BoxShape3D.new()
				box_shape.extents = Vector3(0.0375, 0.005, 0.0375)
				collision_shape.shape = box_shape
				collision_shape.transform.origin = Vector3(0,0,0)
				static_body.add_child(collision_shape)
				
				tile_pos_node.add_child(tile)
				tile_pos_node.add_child(static_body)
				
				var debug_mesh = MeshInstance3D.new()
				debug_mesh.mesh = BoxMesh.new()
				debug_mesh.scale = Vector3(0.07, 0.01, 0.07)
				debug_mesh.material_override = preload("res://debug.tres")
				tile_pos_node.add_child(debug_mesh)
				
				print("Placed Tile Index:", index, "at Position:", tile_position)

func _process(delta: float) -> void:
	var camera: Camera3D = $Camera3D
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	var from: Vector3 = camera.project_ray_origin(mouse_position)
	var to: Vector3 = from + camera.project_ray_normal(mouse_position) * max_distance
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state

	var ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.exclude = [camera] # Optional: Exclude the camera from the raycast

	var result: Dictionary = space_state.intersect_ray(ray_query)

	if result:
		var new_hovered_object: Node3D = result.collider
		if new_hovered_object != hovered_object:
			hovered_object = new_hovered_object
			print("Hovering over: %s" % new_hovered_object.name)
	else:
		if hovered_object != null:
			print("Stopped hovering over: %s" % hovered_object.name)
			hovered_object = null
#	(
#	[][][][][][],
#	[][][][][][],
#	[][][][][][],
#	[][][][][][],
#	[][][][][][],
#	[][][][][][],
#	)
func init_board(shape : String):	# MAX 6x6
	var tiles : Array = []
	for i in range(36):
		var tile_script = preload("res://game_board_tile.gd")  # Ensure this path is correct
		var tile = tile_script.new()
		tiles.append(tile)

	game_board = [
		[tiles[0], tiles[1], tiles[2], tiles[3], tiles[4], tiles[5]],
		[tiles[6], tiles[7], tiles[8], tiles[9], tiles[10], tiles[11]],
		[tiles[12], tiles[13], tiles[14], tiles[15], tiles[16], tiles[17]],
		[tiles[18], tiles[19], tiles[20], tiles[21], tiles[22], tiles[23]],
		[tiles[24], tiles[25], tiles[26], tiles[27], tiles[28], tiles[29]],
		[tiles[30], tiles[31], tiles[32], tiles[33], tiles[34], tiles[35]]
	]
	var to_init : Array = []
	
	print(shape)
	match shape:
		"4round":
			to_init = [
				[0, 0, 0, 0, 0, 0],
				[0, 0, 1, 1, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 1, 1, 0, 0],
				[0, 0, 0, 0, 0, 0]
			]
		"5diamond":
			to_init = [
				[0, 0, 1, 0, 0, 0],
				[0, 1, 1, 1, 0, 0],
				[1, 1, 1, 1, 1, 0],
				[0, 1, 1, 1, 0, 0],
				[0, 0, 1, 0, 0, 0],
				[0, 0, 0, 0, 0, 0]
			]
		"6round":
			to_init = [
				[0, 0, 1, 1, 0, 0],
				[0, 1, 1, 1, 1, 0],
				[1, 1, 1, 1, 1, 1],
				[1, 1, 1, 1, 1, 1],
				[0, 1, 1, 1, 1, 0],
				[0, 0, 1, 1, 0, 0]
			]
		"5x5":
			for i in range(5):
				for j in range(5):
					tiles[i*6 + j].exists = true
			return
		"6x6":
			for i in range(6):
				for j in range(6):
					tiles[i*6 + j].exists = true
			return
	for i in range(6):
		for j in range(6):
			if to_init[i][j] == 1:
				tiles[i*6 + j].exists = true
				
				
	


