extends Node2D

@onready var cursor_ui = preload("res://cursor_ui.tscn")  # Custom cursor UI
@onready var mob_A_scene = preload("res://mob_aa.tscn")        # Mob scene A
@onready var mob_B_scene = preload("res://mob_B.tscn")        # Mob scene B
@onready var mob_C_scene = preload("res://mob_C.tscn")        # Mob scene B
@onready var health_pack = preload("res://health_pack.tscn")
@onready var score_animation = %ScoreAnimation
@onready var multiplier_decay_timer = %MultiplierDecayTimer
@onready var multiplier_label = %MultiplierLabel as Label
@onready var final_score_label = %FinalScoreLabel as Label
@onready var main_menu_button = %MainMenuButton
@onready var pause_menu = $UI/pause_menu
@onready var health_pack_timer = %HealthPackTimer
@onready var tree_manager = $Main_Gameplay/TreeManager
@onready var mob_spawn_timer = $Main_Gameplay/MobSpawnTimer
@onready var game_over = %GameOver
@onready var game_over_sfx  = $Main_Gameplay/GameOver/AudioStreamPlayer
@onready var audio_stream_player = $Main_Gameplay/GameOver/AudioStreamPlayer

var start_time = 0.0                  # Track elapsed time
var active_mobs = []                  # List of currently active mobs
var max_active_mobs = 3               # Initial mob limit
var spawn_interval = 5.0              # Mobs spawn every 5 seconds
var score = 0                         # Player score
var tween: Tween
var multiplier = 1
var multiplier_increase = 1
var max_multiplier = 5
var multiplier_decay_time = 3.0  # Time before multiplier decreases
var min_multiplier = 1  # Minimum multiplier value
var health_pack_instance = null  # Track the active health pack
var current_mob_type = "A"  # Start with Mob A
var next_phase_transition = 60.0  # Time until next phase change

# Phase system
enum PHASE {A, B, C, RANDOM}
var current_phase = PHASE.A
var phase_start_time = 0.0
var phase_duration = 60.0
var phase_data = {}  # UPDATED: Now initialized in _ready()
var can_spawn_mobs = true  # Controls whether mobs can be spawned


func _ready():
	
	phase_data = {
		PHASE.A: {
			"mob_scene": mob_A_scene,
			"max_mobs": [3, 5, 8], 
			"thresholds": [25, 45]
		},
		PHASE.B: {
			"mob_scene": mob_B_scene,
			"max_mobs": [3, 5, 8],
			"thresholds": [25, 45]
		},
		PHASE.C: {
			"mob_scene": mob_C_scene,
			"max_mobs": [3, 5, 8],
			"thresholds": [25, 45]
		},
		PHASE.RANDOM: {
			"mob_scene": [mob_A_scene, mob_B_scene, mob_C_scene],
			"max_mobs": [10],
			"thresholds": []
		}
	}
	
	print("Phase Data Initialized: ", phase_data)
	
	next_phase_transition = 60.0  # Time until next phase change
	# Set up the mob spawn timer
	mob_spawn_timer.wait_time = spawn_interval
	mob_spawn_timer.start()
	get_tree().paused = false  # Ensure the game starts unpaused
	
	health_pack_timer.wait_time = 30.0  # Spawns every 30 sec
	health_pack_timer.timeout.connect(spawn_health_pack)
	health_pack_timer.start()
	
	# Instantiate and add the custom cursor UI
	var cursor_instance = cursor_ui.instantiate()
	add_child(cursor_instance)
	
	# Initialize the multiplier decay timer
	multiplier_decay_timer.wait_time = multiplier_decay_time
	multiplier_decay_timer.one_shot = false
	multiplier_decay_timer.timeout.connect(_on_multiplier_decay)
	
	# Initialize multiplier label
	update_multiplier_label()

	# Spawn initial mobs
	for i in range(max_active_mobs):
		spawn_mob()
	print("Initial mobs spawned. Active mobs: ", active_mobs.size())

func _input(event):
	if event.is_action_pressed("pause"):
		print("Pause key pressed!")
		pause_menu.toggle_pause()

func _process(delta):
	#print("Scene tree paused:", get_tree().paused)  # Debug print
	if get_tree().paused:
		if not mob_spawn_timer.is_stopped():
			mob_spawn_timer.stop()  # Stop the timer when paused
		if not health_pack_timer.is_stopped():
			health_pack_timer.stop()  # Stop the health pack timer when paused
		return  # Exit early when paused

	if mob_spawn_timer.is_stopped():
		mob_spawn_timer.start()  # Resume the timer when unpaused
	if health_pack_timer.is_stopped():
		health_pack_timer.start()  # Resume the health pack timer when unpaused

	# Prevent mob spawning if paused
	if get_tree().paused:
		return 

	tree_manager.spawn_trees_if_needed()
	tree_manager.despawn_trees_out_of_range()

	start_time += delta  # Track the elapsed time

	# Handle phase transitions
	handle_phase_transition()

	# Update max mobs for current phase
	update_max_mobs()

func handle_phase_transition():
	var time_in_phase = start_time - phase_start_time
	
	# Debug logs to track phase transition conditions
	print("Time in phase: ", time_in_phase, " | Active mobs: ", active_mobs.size())
	
	if time_in_phase >= phase_duration && current_phase != PHASE.RANDOM:
		print("Phase duration reached. Stopping mob spawning...")
		can_spawn_mobs = false  # Stop spawning new mobs
		
		if active_mobs.size() == 0:
			print("All mobs cleared. Transitioning to next phase.")
			var new_phase = current_phase + 1
			if new_phase > PHASE.RANDOM:
				new_phase = PHASE.RANDOM
			current_phase = new_phase
			
			phase_start_time = start_time
			can_spawn_mobs = true  # Re-enable mob spawning for the new phase
			print("Phase changed to: ", PHASE.keys()[current_phase])
			
			# Reset mob limits for new phase
			var phase_info = phase_data.get(current_phase, {})
			max_active_mobs = phase_info.get("max_mobs", [3])[0]
		else:
			print("Mobs still active. Waiting for all mobs to be cleared...")
	else:
		print("Phase duration not reached or already in RANDOM phase.")

# Update max mobs based on phase and elapsed time
func update_max_mobs():
	var time_in_phase = start_time - phase_start_time
	var data = phase_data.get(current_phase, {})
	
	if data.is_empty():
		push_error("No data for current phase: ", current_phase)
		return
	
	var base_mobs = data.get("max_mobs", [3])
	var thresholds = data.get("thresholds", [])
	
	var new_max = base_mobs[0]
	for i in range(thresholds.size()):
		if time_in_phase >= thresholds[i] && (i + 1) < base_mobs.size():
			new_max = base_mobs[i + 1]
	
	if max_active_mobs != new_max:
		max_active_mobs = new_max
		print("New max mobs: ", max_active_mobs)

func spawn_mob():
	if get_tree().paused or not can_spawn_mobs:  # Respect can_spawn_mobs
		return
	
# Get phase data with null check
	var data = phase_data.get(current_phase, {})
	if data.is_empty():
		push_error("Invalid phase data for phase: ", current_phase)
		return
	
	# Get mob scene with fallback
	var mob_scene
	if current_phase == PHASE.RANDOM:
		mob_scene = data["mob_scene"].pick_random() if data.has("mob_scene") else null
	else:
		mob_scene = data.get("mob_scene", null)
	
	if not mob_scene:
		push_error("No mob scene found for phase: ", current_phase)
		return
	
	print("Spawning mob from scene: ", mob_scene.resource_path.get_file(), " | Phase: ", PHASE.keys()[current_phase])
	
	var new_mob = mob_scene.instantiate()
	new_mob.position = get_random_position_near_player()
	new_mob.connect("mob_destroyed", Callable(self, "_on_mob_destroyed"))
	
	# Use call_deferred to add the child after the physics frame is complete
	get_node("/root/Game/Main_Gameplay").call_deferred("add_child", new_mob)
	active_mobs.append(new_mob)
	print("Spawned a mob. Active mobs: ", active_mobs.size())  # Debug log

# Signal handler for mob destruction
func _on_mob_destroyed(mob, base_score):
	# Remove the mob from the active list
	if mob in active_mobs:
		active_mobs.erase(mob)  
	
	# Handle phase transition attempts when mobs are cleared
	if active_mobs.size() == 0 && start_time >= next_phase_transition:
		handle_phase_transition()
	
	# Increase multiplier and reset decay timer
	multiplier += multiplier_increase
	multiplier = min(multiplier, max_multiplier)  # Clamp to max multiplier
	update_multiplier_label()

	# Add score with multiplier
	add_score(base_score * multiplier)

	# Reset and restart decay timer
	multiplier_decay_timer.start()
	
	print("Mob destroyed. Active mobs: ", active_mobs.size())  # Debug log
	
	# Only spawn new mobs if allowed
	if can_spawn_mobs && active_mobs.size() < max_active_mobs:
		spawn_mob()

func add_score(amount):
	score += amount  # Increase the player's score
	score_animation.update_number(score)  # Call the score animation script

func update_multiplier_label():
	multiplier_label.text = "X" + str(multiplier)
	
	var tween = get_tree().create_tween()
	
	# Scale up slightly for a bounce effect
	tween.tween_property(multiplier_label, "scale", Vector2(1.3, 1.3), 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Scale back to normal smoothly
	tween.tween_property(multiplier_label, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

# Random position near the player
func get_random_position_near_player() -> Vector2:
	var player_position = get_node("/root/Game/Main_Gameplay/Player").global_position
	var angle = randf() * TAU
	var min_distance = 300.0
	var max_distance = 600.0
	var offset = Vector2(cos(angle), sin(angle)) * randf_range(min_distance, max_distance)
	return player_position + offset

# Game over logic
func _on_player_health_depleted():
	%GameOver.visible = true
	if game_over_sfx:  # Check if the MusicStreamPlayer exists
		print("Playing game over SFX...")
		game_over_sfx.play()  # Play the sound effect
	else:
		print("Game over SFX not found!")  # Debug message if the player isn't valid
	main_menu_button.visible = true  # Ensure the button is visible too
	main_menu_button.set_process_unhandled_input(true)  # Make sure it can receive input
	get_tree().paused = true
	
	mob_spawn_timer.stop()
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Display final score
	%FinalScoreLabel.text = "" + str(score)
	
	# Check if it's a new high score and update it
	var high_score = get_high_score()
	if score > high_score:
		save_high_score(score)

func get_high_score():
	if ProjectSettings.has_setting("user://high_scores"):
		return int(ProjectSettings.get_setting("user://high_scores"))
	return 0  # Default high score if no previous record exists

func save_high_score(new_score: int):
	print("Saving High Score...") 
	var file_path = "user://high_scores.json"
	var scores = []
	
	# Load existing scores if the file exists
	if FileAccess.file_exists(file_path):
		print("File exists. Reading current scores...")
		var file = FileAccess.open(file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
	
		var json = JSON.new()
		var error = json.parse(content)
		if error == OK:
			scores = json.data if json.data is Array else []
			print("Current High Scores:", scores)
		else:
			print("Error parsing JSON:", json.get_error_message())
	
	# Get player's name (from the main menu)
	var player_name = Global.player_name if Global.player_name else "Unknown"
	print("Player Name:", player_name)
	
	# Append new score entry (name + score)
	scores.append({"name": player_name, "score": new_score})
	print("Added new score:", {"name": player_name, "score": new_score})
	
	# Sort scores (highest first)
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	
	# Keep only the top 5 scores
	while scores.size() > 5:
		scores.pop_back()

	# Save back to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores))
	file.close()
	print("High scores saved successfully!")

func _on_multiplier_decay():
	if multiplier > min_multiplier:
		multiplier -= 1
		update_multiplier_label()
		print("Multiplier decayed. New multiplier:", multiplier)

	# Stop timer if multiplier reaches minimum value
	if multiplier == min_multiplier:
		multiplier_decay_timer.stop()

# Timer timeout logic (if needed)
func _on_timer_timeout():
	print("Timer timed out.")
	# Add logic for spawning mobs or other timer-based functionality

func _on_mob_spawn_timer_timeout():
	print("Spawn timer triggered. Active mobs:", active_mobs.size(), "/", max_active_mobs)
	
	# Spawn mobs until we reach the maximum
	while active_mobs.size() < max_active_mobs:
		spawn_mob()

func spawn_health_pack():
	if health_pack_instance:  # If one exists, don't spawn another
		return

	health_pack_instance = health_pack.instantiate()
	health_pack_instance.position = get_random_position_near_player()  # Use the existing function
	get_tree().current_scene.add_child(health_pack_instance)

	# Add a log to confirm it's spawning
	print("Health pack spawned at:", health_pack_instance.position)

	# Remove reference when collected
	health_pack_instance.tree_exited.connect(_on_health_pack_removed)

func _on_health_pack_removed():
	health_pack_instance = null  # Reset so another can spawn

func reset_multiplier():
	#print("Multiplier Reset!")  # Debug log
	multiplier = 1
	multiplier_label.text = "X" + str(multiplier)

func _on_main_menu_button_pressed():
	print("Button Clicked!")  # First check if this appears in logs
	get_tree().paused = false  # Unpause the game
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.player_name = ""
	var err = get_tree().change_scene_to_file("res://main_menu.tscn")
	print("Scene Change Result:", err)  # Check if scene change is failing
