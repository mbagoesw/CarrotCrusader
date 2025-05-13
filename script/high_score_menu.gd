extends Control

const SAVE_FILE = "user://high_scores.json"

@onready var rank_labels = [$MarginContainer/ScoreTable/Row1/Rank_Label_1, $MarginContainer/ScoreTable/Row2/Rank_Label_2, $MarginContainer/ScoreTable/Row3/Rank_Label_3, $MarginContainer/ScoreTable/Row4/Rank_Label_4, $MarginContainer/ScoreTable/Row5/Rank_Label_5]
@onready var score_labels = [$MarginContainer/ScoreTable/Row1/Score_Label_1, $MarginContainer/ScoreTable/Row2/Score_Label_2, $MarginContainer/ScoreTable/Row3/Score_Label_3, $MarginContainer/ScoreTable/Row4/Score_Label_4, $MarginContainer/ScoreTable/Row5/Score_Label_5]
@onready var name_labels = [$MarginContainer/ScoreTable/Row1/Name_Label_1, $MarginContainer/ScoreTable/Row2/Name_Label_2, $MarginContainer/ScoreTable/Row3/Name_Label_3, $MarginContainer/ScoreTable/Row4/Name_Label_4, $MarginContainer/ScoreTable/Row5/Name_Label_5]
@onready var exit_button = $MarginContainer/ScoreTable/Exit_Button

signal exit_highscore_menu

func _ready():
	exit_button.button_down.connect(on_exit_pressed)
	update_high_score_display()

func on_exit_pressed() -> void:
	exit_highscore_menu.emit()
	set_process(false)

func save_high_score(new_score: int):
	var scores = load_high_scores()

	# Save score with player name
	scores.append({"name": Global.player_name, "score": new_score})

	# Sort scores (highest first) and keep top 5
	scores.sort_custom(func(a, b): return a["score"] > b["score"])
	scores = scores.slice(0, 5)

	# Save back to file
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(scores))
	file.close()

func update_high_score_display():
	var scores = load_high_scores()
	
	for i in range(5):  
		if i < scores.size():
			rank_labels[i].text = str(i + 1)  # Rank
			score_labels[i].text = str(scores[i].get("score", "-"))  # Score
			name_labels[i].text = scores[i].get("name", "Unknown")  # Player Name
		else:
			rank_labels[i].text = "-"
			score_labels[i].text = "-"
			name_labels[i].text = "-"

# **Loads scores from file**
func load_high_scores() -> Array:
	if not FileAccess.file_exists(SAVE_FILE):
		return []
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		return []
	
	var data = json.data
	return data if data is Array else []
