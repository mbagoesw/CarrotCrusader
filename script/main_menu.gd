class_name MainMenu
extends Control

@onready var play_button = $MarginContainer/HBoxContainer/VBoxContainer/Play_Button as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/Quit_Button as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/Options_Button as Button
@onready var options_menu = $Options_Menu as OptionsMenu
@onready var margin_container = $MarginContainer as MarginContainer
#@onready var start_level = preload("res://survivors_game.tscn")
@onready var high_score_button = $MarginContainer/HBoxContainer/VBoxContainer/HighScore_Button as Button
@onready var high_score_menu = $HighScore_Menu
@onready var player_name_input = $MarginContainer/HBoxContainer/VBoxContainer/PlayerNameInput
@onready var animation_player = $AnimationPlayer
@onready var press_label = $Press_Label
@onready var loading_screen = preload("res://scenes/loading_screen.tscn")
@onready var credits_menu = $Credits_Menu
@onready var credits_button = $MarginContainer/HBoxContainer/VBoxContainer/Credits_Button as Button


var waiting_for_input = true

func _ready():
	margin_container.visible = false
	start_blinking()
	
	handle_connecting_signals()
	player_name_input.placeholder_text = "Insert Player Name"
	player_name_input.text = Global.player_name
	
	# Remove this line so the button is never disabled
	# play_button.disabled = true  
	
	if not player_name_input.text_changed.is_connected(_on_player_name_input_text_changed):
		player_name_input.text_changed.connect(_on_player_name_input_text_changed)

func _input(event):
	if waiting_for_input and (event is InputEventKey or event is InputEventMouseButton):
		transition_to_main_menu()

func on_play_pressed() -> void:
	if Global.player_name == "":
		shake_input_field()  # Shake effect if no name entered
		print("Play button clicked, but name is empty!")  # Debugging
		return  # Don't proceed if name is empty
	
	print("Starting game with player:", Global.player_name) 
	
	#Global.player_name = ""
	
	#Loading Screen
	var loading_instance = loading_screen.instantiate()
	get_tree().current_scene.add_child(loading_instance)  # Show the loading screen
	loading_instance.start_loading("res://scenes/main_gameplay.tscn")  # Start loading

func on_options_pressed() -> void:
	margin_container.visible = false
	options_menu.set_process(true)
	options_menu.visible = true

func on_exit_options_menu() -> void:
	margin_container.visible = true
	options_menu.visible = false

func on_quit_pressed() -> void:
	get_tree().quit()

func on_highscore_pressed() -> void:
	margin_container.visible = false
	high_score_menu.set_process(true)
	high_score_menu.visible = true

func on_exit_highscore_menu() -> void:
	margin_container.visible = true
	high_score_menu.visible = false

func on_credits_pressed() -> void:
	margin_container.visible = false
	credits_menu.set_process(true)
	credits_menu.visible = true

func on_exit_credits_menu() -> void:
	margin_container.visible = true
	credits_menu.visible = false

func handle_connecting_signals() -> void:
	play_button.button_down.connect(on_play_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_quit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	high_score_menu.exit_highscore_menu.connect(on_exit_highscore_menu)
	high_score_button.button_down.connect(on_highscore_pressed)
	credits_menu.exit_credits_menu.connect(on_exit_credits_menu)
	credits_button.button_down.connect(on_credits_pressed)
	#player_name_input.text_changed.connect(_on_player_name_input_text_changed)

func _on_player_name_input_text_changed(new_text):
	Global.player_name = new_text.strip_edges()  # Trim spaces
	#play_button.disabled = Global.player_name == ""
	print("Updated player name to:", Global.player_name)

func shake_input_field():
	var start_pos = player_name_input.position
	var shake_strength = 5.0
	
	var tween = get_tree().create_tween()
	# Tween effect to shake the input field
	tween.tween_property(player_name_input, "position", start_pos + Vector2(shake_strength, 0), 0.05)
	tween.tween_property(player_name_input, "position", start_pos - Vector2(shake_strength, 0), 0.05)
	tween.tween_property(player_name_input, "position", start_pos + Vector2(shake_strength, 0), 0.05)
	tween.tween_property(player_name_input, "position", start_pos, 0.05)

func start_blinking():
	while waiting_for_input:
		var tween = create_tween()
		tween.tween_property(press_label, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_LINEAR)
		await tween.finished  # Wait for the fade-out to complete
		
		tween = create_tween()  # Create a new tween for fade-in
		tween.tween_property(press_label, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_LINEAR)
		await tween.finished  # Wait for the fade-in to complete

func transition_to_main_menu():
	waiting_for_input = false  # Stop input detection
	press_label.visible = false  # Hide press label
	
	# Play animation to move logo up and shrink it
	animation_player.play("transition")

	# Show menu buttons after animation
	await get_tree().create_timer(0.7).timeout
	margin_container.visible = true  # Reveal buttons
