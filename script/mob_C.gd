extends CharacterBody2D

# Define the signal for when the mob is destroyed
signal mob_destroyed(score_value)

var health = 8  # Mob health
@onready var player = get_node("/root/Game/Main_Gameplay/Player")  # Reference to the player
@onready var smoke_scene = preload("res://smoke_explosion/smoke_explosion.tscn")  # Smoke effect
@onready var hit_sound = %MobsHit # Mobs getting hit sfx
@onready var mobs_death = %MobsDeath # Mobs Death


# Variables for preventing sound spam
var can_play_sound: bool = true
const SOUND_COOLDOWN: float = 0.2  # Cooldown time in seconds (adjust as needed)

func _ready():
	%BunnyC.play_walk()  # Play walk animation

func _physics_process(delta):
	if get_tree().paused:
		velocity = Vector2.ZERO  # Stop the mob from moving
		return

	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 300.0
	move_and_slide()


# Called when the mob takes damage
func take_damage():
	if not can_play_sound:
		return  # Exit early if the cooldown is active
	
	# Check if this hit will kill the mob
	if health > 1:
		play_hit_sound()  # Only play hit sound if the mob is not about to die
	
	health -= 1
	%BunnyC.play_hurt()  # Play hurt animation
	
	if health <= 0:
		_destroy_mob()

# Called when the mob is destroyed
func _destroy_mob():
	emit_signal("mob_destroyed",self, 400)  # Emit the signal that the mob is destroyed and give score 400
	
	# Spawn smoke effect
	var smoke = smoke_scene.instantiate()
	get_parent().add_child(smoke)
	smoke.global_position = global_position
	
	# Move the death sound outside the mob so it doesn't get deleted
	mobs_death.get_parent().remove_child(mobs_death) 
	get_parent().add_child(mobs_death)  # Attach it to the parent scene
	mobs_death.play()  # Play death sound
	
	## Create a Tween for fade-out
	#var tween = get_tree().create_tween()
	#tween.tween_property(mobs_death, "volume_db", -40, 1.5)  # Fades out over 1.5 seconds
	
	queue_free()  # Free the mob from the scene


# Function to play the hit sound with cooldown
func play_hit_sound():
	if can_play_sound:
		hit_sound.play()  # Play the sound effect
		can_play_sound = false  # Disable sound playback temporarily

		# Start a cooldown timer
		await get_tree().create_timer(SOUND_COOLDOWN).timeout
		can_play_sound = true  # Re-enable sound playback after the cooldown
