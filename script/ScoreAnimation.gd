extends Control

@onready var current_score = $CurrentScore
@onready var incoming_score = $IncomingScore

var current_number: float = 0.0  # Use float for smooth animation
var target_number: int = 0  # Keep target as an int
var animating = false
var animation_speed = 0.35  # Adjust for speed (higher = faster)

func update_number(new_number):
	if target_number == new_number:
		return  # Prevent unnecessary updates

	target_number = new_number
	animating = true
	animate_number_change()

func animate_number_change():
	if not animating:
		return

	# Smoothly interpolate with lerp, converting target_number to float
	current_number = lerp(current_number, float(target_number), animation_speed)

	# Ensure proper rounding
	if abs(target_number - current_number) < 1:
		current_number = target_number  # Snap to the final number
		animating = false  # Stop animation

	# Convert number to a 6-digit string
	var display_number = int(current_number)
	var padded_number = str(display_number).pad_zeros(7)

	# Update the labels
	current_score.text = padded_number
	incoming_score.text = padded_number

	if animating:
		await get_tree().create_timer(0.02).timeout  # Controls the animation update rate
		animate_number_change()
