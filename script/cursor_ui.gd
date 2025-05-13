extends Node2D

@onready var cursor_sprite = $Crosshair

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Hide default cursor
	cursor_sprite.visible = false  # Start hidden for the tutorial

func _process(delta):
	cursor_sprite.global_position = get_global_mouse_position()  # Update position when active

# Call this function when tutorial starts
func hide_cursor():
	self.visible = false
	set_process(false)  # Stop updating position

func show_cursor():
	print("show_cursor() called!")  # Debugging
	self.visible = true
	cursor_sprite.visible = true  # Ensure crosshair is visible
	set_process(true)  # Resume updating position
	print("CursorUI visible:", self.visible, "| Cursor Sprite visible:", cursor_sprite.visible)


