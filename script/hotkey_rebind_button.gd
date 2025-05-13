class_name HotkeyRebindButton
extends Control

@onready var label = $HBoxContainer/Label as Label
@onready var button = $HBoxContainer/Button as Button
@export var action_name: String = "move_left"

var awaiting_input: bool = false  # Tracks if waiting for user input
var original_mouse_filter: int  # Stores the original mouse filter value

func _ready():
	remove_default_ui_actions()
	set_process_unhandled_input(false)  # Initially disable input capture
	set_action_name()
	update_button_text()

# Removes unnecessary UI shortcuts
func remove_default_ui_actions():
	var actions_to_remove = ["ui_cut", "ui_copy", "ui_paste", "ui_undo", "ui_redo"]
	for action in actions_to_remove:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			#print("Removed bindings for:", action)

func set_action_name() -> void:
	match action_name:
		"move_left":
			label.text = "Move Left"
		"move_right":
			label.text = "Move Right"
		"move_down":
			label.text = "Move Down"
		"move_up":
			label.text = "Move Up"
		"shoot":
			label.text = "Shoot"
		_:  # This will catch any unknown action names
			print(" Unknown action name:", action_name)
			label.text = "Unknown Action"


# Updates the button text based on the current keybinding
func update_button_text() -> void:
	var action_events = InputMap.action_get_events(action_name)
	print("Fetching action:", action_name, "Found events:", action_events)  # Debugging
	if action_events.size() > 0:
		var event = action_events[0]
		if event is InputEventKey:
			button.text = OS.get_keycode_string(event.physical_keycode)  # Use `physical_keycode`
		elif event is InputEventMouseButton:
			button.text = mouse_button_to_string(event.button_index)
		else:
			button.text = "Unknown"
	else:
		button.text = "Unassigned"


# Handles input during key rebinding
func _unhandled_input(event):
	if awaiting_input:
		if (event is InputEventKey and event.pressed) or (event is InputEventMouseButton and event.pressed):
			rebind_action(event)
			awaiting_input = false
			set_process_unhandled_input(false)
			restore_mouse_filter()  # Restore the original mouse filter

# Rebinds the action to a new input
func rebind_action(event: InputEvent) -> void:
	if not event:
		return
	var action_key: String
	if event is InputEventKey:
		action_key = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		action_key = mouse_button_to_string(event.button_index)
	else:
		return
	# Check for duplicate bindings
	if is_key_already_bound(event):
		button.text = "'" + action_key + "' already bound"
		await get_tree().create_timer(2.0).timeout
		update_button_text()
		return
	# Remove old bindings and assign the new one
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	print("Successfully bound:", action_name, "to", action_key)
	update_button_text()

# Converts mouse button index to string
func mouse_button_to_string(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT: return "Left Click"
		MOUSE_BUTTON_RIGHT: return "Right Click"
		MOUSE_BUTTON_MIDDLE: return "Middle Click"
		MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
	return "Unknown Mouse Button"

# Checks if the key is already bound to another action
func is_key_already_bound(event: InputEvent) -> bool:
	print("Checking if", event, "is already bound...")  # Debugging

	for action in InputMap.get_actions():
		print("Checking action:", action)  # Debugging
		for assigned_event in InputMap.action_get_events(action):
			print("  Assigned event:", assigned_event)  # Debugging

			if event is InputEventKey and assigned_event is InputEventKey:
				if event.keycode == assigned_event.keycode or event.physical_keycode == assigned_event.physical_keycode:
					print("  Conflict detected! Key already bound to:", action)
					return true
			elif event is InputEventMouseButton and assigned_event is InputEventMouseButton:
				if event.button_index == assigned_event.button_index:
					print("  Conflict detected! Mouse button already bound to:", action)
					return true

	print("No conflict found!")
	return false



# When the rebind button is pressed
func _on_button_pressed():
	awaiting_input = true
	set_process_unhandled_input(true)
	button.text = "Press a Key or Click..."
	ignore_mouse_filter()  # Temporarily ignore mouse input for the button

# Temporarily ignore mouse input for the button
func ignore_mouse_filter() -> void:
	original_mouse_filter = button.mouse_filter  # Save the original mouse filter
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Ignore mouse input

# Restore the original mouse filter
func restore_mouse_filter() -> void:
	button.mouse_filter = original_mouse_filter  # Restore the original mouse filter
