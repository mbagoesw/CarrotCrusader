extends Node2D

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse Button Detected:", event.button_index, "Pressed:", event.pressed)
