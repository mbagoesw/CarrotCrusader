class_name HealthPack
extends Area2D

@export var heal_amount: float = 0.25  # 25% of max health

func _ready():
	if not body_entered.is_connected(_on_body_entered):  
		body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.has_method("heal"):  # If the player has a heal function
		body.heal(heal_amount)  # Restore health
		queue_free()  # Remove the health pack
