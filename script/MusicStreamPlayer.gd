extends AudioStreamPlayer

@export var fade_duration: float = 4.0  # Duration of the fade-in (seconds)
@export var start_volume: float = -40  # Starting volume (dB)
@export var target_volume: float = 0  # Target volume (dB)

func _ready():
	volume_db = start_volume  # Set initial volume
	play()  # Start playing the music
	fade_in()  # Call the fade-in function

func fade_in():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "volume_db", target_volume, fade_duration)
