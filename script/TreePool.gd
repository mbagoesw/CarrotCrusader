extends Node2D

@export var tree_scene: PackedScene
var pool: Array = []

# Fetch a tree from the pool or create a new one
func fetch_tree() -> Node2D:
	if pool.size() > 0:
		return pool.pop_back()
	return tree_scene.instantiate()

# Return tree to the pool for reuse instead of deleting
func return_tree(tree: Node2D):
	tree.hide()  # Hide tree before adding it to the pool
	pool.append(tree)
	tree.reparent(self)  # Move the tree back to the pool
