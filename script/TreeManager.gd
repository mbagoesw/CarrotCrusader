extends Node2D

# Exported Variables
@export var spawn_distance: float = 800.0
@export var despawn_distance: float = 1000.0
@export var max_trees: int = 4
@onready var tree_pool = get_node("/root/Game/Main_Gameplay/TreePool")  # Reference to the pool
@onready var player = get_node("/root/Game/Main_Gameplay/Player")  # Reference to the player

# Active Trees Array
var active_trees: Array = []

func _process(delta):
	spawn_trees_if_needed()
	despawn_trees_out_of_range()

# Spawn trees only when necessary
func spawn_trees_if_needed():
	if max_trees <= 0:
		return  # Don't spawn any trees if max_trees is 0 or negative
	
	while active_trees.size() < max_trees:
		var spawn_position = get_random_position_near_player()
		
		if not is_spawn_position_valid(spawn_position):
			continue
		
		var tree = tree_pool.fetch_tree()
		if tree.get_parent():
			tree.get_parent().remove_child(tree)  # Ensure the tree has no parent
		
		tree.global_position = spawn_position
		tree.show()  # Make sure the tree is visible
		add_child(tree)
		active_trees.append(tree)
		#print("Spawned a tree at position: ", spawn_position)
		return

# Despawn trees that are too far from the player
func despawn_trees_out_of_range():
	var player_pos = player.get_node("Camera2D").global_position
	var trees_to_remove = []
	
	for tree in active_trees:
		if tree.global_position.distance_to(player_pos) > despawn_distance:
			trees_to_remove.append(tree)
	
	for tree in trees_to_remove:
		tree_pool.return_tree(tree)
		active_trees.erase(tree)
		#print("Despawned tree at position: ", tree.global_position)

# Get a random position near the player
func get_random_position_near_player() -> Vector2:
	var player_pos = player.get_node("Camera2D").global_position
	var angle = randf() * TAU  # Random angle (0 - 360 degrees)
	var random_radius = spawn_distance * randf_range(0.8, 1.2)  # Randomize radius within 80% to 120% of spawn_distance
	var offset = Vector2(cos(angle), sin(angle)) * random_radius
	return player_pos + offset

# Ensure trees don't spawn in invalid areas
func is_spawn_position_valid(position: Vector2) -> bool:
	for tree in active_trees:
		if position.distance_to(tree.global_position) < 100:  # Minimum distance between trees
			return false
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_bodies = true
	query.collide_with_areas = true
	
	return space_state.intersect_point(query).is_empty()  # If empty, it's a valid spawn location
