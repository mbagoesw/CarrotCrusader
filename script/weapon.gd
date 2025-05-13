extends Area2D

@onready var shooting_point = $WeaponPivot/Bow/ShootingPoint
const ARROW = preload("res://arrow.tscn")

func _ready():
	# Debug to ensure ShootingPoint exists
	if shooting_point == null:
		print("Error: ShootingPoint is null! Check the hierarchy.")
	else:
		print("ShootingPoint loaded successfully.")

func _process(delta):
	# Rotate the gun to face the mouse cursor
	var mouse_position = get_global_mouse_position()
	var direction = mouse_position - global_position
	rotation = direction.angle()

func shoot():
	if shooting_point == null:
		print("Error: Cannot shoot because ShootingPoint is null!")
		return
	
	var new_arrow = ARROW.instantiate()
	new_arrow.global_position = shooting_point.global_position
	new_arrow.rotation = shooting_point.global_rotation
	get_tree().get_root().add_child(new_arrow)
	#print("Arrow shot from:", shooting_point.global_position)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.is_action_pressed("shoot"):
		shoot()

#extends Area2D
#
#
#func _physics_process(delta):
	#var enemies_in_range = get_overlapping_bodies()
	#if enemies_in_range.size() > 0:
		#var target_enemy = enemies_in_range.front()
		#look_at(target_enemy.global_position)
#
#
#func shoot():
	#const BULLET = preload("res://bullet.tscn")
	#var new_bullet = BULLET.instantiate()
	#new_bullet.global_position = %ShootingPoint.global_position
	#new_bullet.global_rotation = %ShootingPoint.global_rotation
	#%ShootingPoint.add_child(new_bullet)
#
#
#func _on_timer_timeout():
	#shoot()
