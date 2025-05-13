extends CharacterBody2D

signal health_depleted

var health = 100.0
@onready var main_scene = get_tree().get_root().get_node("Game") # Reference main scene
@onready var multiplier_decay_timer = main_scene.get_node("Main_Gameplay/MultiplierDecayTimer")  # Correct timer path

const DAMAGE_RATE = 10.0
var can_take_damage = true  # Prevents constant multiplier resets

func _ready():
	multiplier_decay_timer.wait_time = 0.5  # Repurpose this timer as a damage cooldown
	multiplier_decay_timer.one_shot = true  # Ensure it only triggers once per hit

func _physics_process(delta):
	# Handle player movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * 600
	move_and_slide()
	
	# Play appropriate animations
	if velocity.length() > 0.0:
		%carrot_knightt.play_walk_animation()
	else:
		%carrot_knightt.play_idle_animation()

	# Handle health reduction when overlapping mobs
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	#print("Overlapping mobs: ", overlapping_mobs.size(), " | Health: ", health, " | Can take damage: ", can_take_damage)
	if overlapping_mobs.size() > 0:
		take_damage(overlapping_mobs.size(), delta)

func take_damage(mob_count, delta):
	health -= DAMAGE_RATE * mob_count * delta
	%ProgressBar.value = health
	
	# Reset multiplier
	main_scene.reset_multiplier()
	
	# **Start cooldown using decay timer**
	
	if health <= 0.0:
		health_depleted.emit()

func heal(amount: float):
	var heal_value = 100.0 * amount  # 100 is the max health (if it's fixed)
	health = min(health + heal_value, 100.0)  # Prevent overhealing
	%ProgressBar.value = health  # Update health bar
	print("Player healed for", heal_value, "HP! Current Health:", health)

