extends ColorRect

@onready var fade_animation_player = $FadeAnimationPlayer
@onready var tutorial_animation_player = $TutorialAnimationPlayer
@onready var cursor_ui = get_tree().get_first_node_in_group("CursorUI")  # Get Cursor UI

func _ready():
	await get_tree().process_frame  # Wait for one frame
	cursor_ui = get_tree().get_first_node_in_group("CursorUI")  
	print("Cursor UI fetched:", cursor_ui)  # Debugging  
	
	print("Tutorial script is running!")
	Global.load_tutorial()
	print("Global.tutorial_seen:", Global.tutorial_seen)
	
	# Skip tutorial if already seen
	if Global.tutorial_seen:
		print("Tutorial already seen. Skipping tutorial screen.")
		queue_free()
		return
	
	# Ensure the tutorial is always shown (for debugging)
	self.visible = true
	modulate.a = 1.0  

	# Ensure it stays on screen and scales properly
	self.set_deferred("size", get_viewport_rect().size)  
	self.set_deferred("position", Vector2(0, 0))  
	self.set_deferred("z_index", 999)  
	print("Tutorial UI forced to be visible and in front!")

	# Manually pause all gameplay nodes
	for node in get_tree().get_nodes_in_group("Main_Gameplay"):
		node.set_process_mode(Node.PROCESS_MODE_DISABLED)
	print("Manually paused all gameplay nodes.")

	# Hide both system cursor & custom cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	if cursor_ui:
		cursor_ui.hide_cursor()
		print("Cursor hidden successfully.")
	else:
		print("Cursor UI still NULL!")

	# Wait a short time before playing animations
	await get_tree().create_timer(0.1).timeout  

	# Play both animations at the same time
	fade_animation_player.play("fade_in")
	tutorial_animation_player.play("Tutorial")

	print("Fade-in animation playing?", fade_animation_player.is_playing())
	print("Tutorial animation playing?", tutorial_animation_player.is_playing())

# Function to set hole position in shader
func set_hole_position(new_position: Vector2):
	print("Changing hole position to:", new_position)  # Debugging
	material.set_shader_parameter("hole_position", new_position)

# Function to set hole size in shader
func set_hole_size(new_size: Vector2):
	print("Changing hole size to:", new_size)  # Debugging
	material.set_shader_parameter("hole_size", new_size)

# Function to resume the game when the tutorial is finished
func _on_tutorial_finished():
	print("Tutorial finished, resuming game.")
	
	Global.tutorial_seen = true
	Global.save_tutorial()
	
	# Manually unpause all gameplay nodes
	for node in get_tree().get_nodes_in_group("Main_Gameplay"):
		node.set_process_mode(Node.PROCESS_MODE_INHERIT)

	print("Manually unpaused all gameplay nodes.")

	# Show the cursor again
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if cursor_ui:
		print("Calling cursor_ui.show_cursor()")
		cursor_ui.show_cursor()  # Show custom cursor
	else:
		print("cursor_ui is NULL!")

	self.visible = false  
	queue_free()
