extends Control

@onready var progress_bar = $ProgressBar
@onready var loading_label = $LoadingLabel

var next_scene_path = ""  # Scene path to load
var load_progress = [0.0]  # Progress tracking

func start_loading(target_scene_path: String):
	next_scene_path = target_scene_path  # Store the scene path
	progress_bar.value = 0  # Start from 0
	var tween = get_tree().create_tween()

	# Create a smooth tween from 0 to 100 over 2 seconds
	tween.tween_property(progress_bar, "value", 100, 2.0).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

	await tween.finished  # Wait for the tween to complete

	# Load the actual scene after progress bar completes
	get_tree().change_scene_to_file(next_scene_path)
