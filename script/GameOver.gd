extends CanvasLayer

@onready var main_menu_button = %MainMenuButton
@onready var main_gameplay = get_tree().get_root().get_node("Game/Main_Gameplay") as Node  # Ensure it's treated as a node

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	if main_gameplay and main_gameplay.has_method("_on_main_menu_button_pressed"):
		if not main_menu_button.pressed.is_connected(main_gameplay._on_main_menu_button_pressed):
			main_menu_button.pressed.connect(main_gameplay._on_main_menu_button_pressed)
	else:
		print("Error: Main_Gameplay does not have _on_main_menu_button_pressed method!")
