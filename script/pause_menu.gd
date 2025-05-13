class_name PauseMenu
extends Control

@onready var margin_container = $MarginContainer
@onready var resume_button = $MarginContainer/Panel/VBoxContainer/resume_button as Button
@onready var options_button = $MarginContainer/Panel/VBoxContainer/options_button as Button
@onready var main_menu_button = $MarginContainer/Panel/VBoxContainer/main_menu_button as Button
@onready var options_menu = $Options_Menu as OptionsMenu


func _ready():
	set_process_unhandled_input(true)
	print("PauseMenu script is running!")
	handle_connecting_signals()
	self.visible = false  # Start with the Pause Menu hidden

func handle_connecting_signals():
	print("handle_connecting_signals() is running")
	resume_button.button_down.connect(_on_resume_button_pressed)
	options_button.button_down.connect(_on_options_button_pressed)
	main_menu_button.button_down.connect(_on_main_menu_button_pressed)
	
	if not options_menu.exit_options_menu.is_connected(_on_options_menu_exit_options_menu):
		options_menu.exit_options_menu.connect(_on_options_menu_exit_options_menu)
		print("Connected exit_options_menu signal to _on_options_menu_exit_options_menu")
	else:
		print("Signal already connected!")

func _unhandled_input(event):
	if event.is_action_pressed("pause"):  # "pause" should be mapped to "Esc" in InputMap
		print("Pause key pressed!")  # Debug log
		toggle_pause()

func _input(event):
	if event.is_action_pressed("pause"):
		print("Pause key pressed!")
		
		# Wait for the next frame before processing the toggle to prevent double triggering
		await get_tree().process_frame  
		
		# If options menu is open, close it first, otherwise toggle pause menu
		if options_menu.visible:
			_on_options_menu_exit_options_menu()
		else:
			toggle_pause()


func toggle_pause():
	var is_now_paused = not get_tree().paused  # Toggle pause state
	get_tree().paused = is_now_paused  
	self.visible = is_now_paused  # Ensure Pause Menu is visible when paused
	
	print("Pausing game..." if is_now_paused else "Unpausing game...")
	
	if is_now_paused:
		self.show()
		self.process_mode = Node.PROCESS_MODE_ALWAYS
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		self.hide()
		self.process_mode = Node.PROCESS_MODE_INHERIT
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_resume_button_pressed():
	print("Resume button pressed!")  # Debugging log
	get_tree().paused = false  # Unpause the game
	self.visible = false  # Hide the pause menu
	self.process_mode = Node.PROCESS_MODE_INHERIT  # Restore normal processing
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)  # Hide cursor again


func _on_options_button_pressed():
	margin_container.visible = false  # Hide the Pause Menu UI
	options_menu.visible = true  # Show the Options Menu
	options_menu.set_process(true)

func _on_main_menu_button_pressed():
	get_tree().paused = false  # Unpause before returning to the Main Menu
	Global.player_name = ""
	get_tree().change_scene_to_file("res://main_menu.tscn")  # Change to Main Menu

func _on_options_menu_exit_options_menu():
	margin_container.visible = true  # Show the Pause Menu UI
	options_menu.visible = false  # Hide the Options Menu



