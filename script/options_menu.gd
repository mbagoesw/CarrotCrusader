class_name OptionsMenu
extends Control

#@onready var exit_button = $MarginContainer/VBoxContainer/Exit_Button as Button
#@onready var exit_button = $Panel/ScrollContainer/MarginContainer/VBoxContainer/Exit_Button as Button
@onready var settings_tab = $MarginContainer/VBoxContainer/Settings_Tab_Container

signal exit_options_menu

func _ready():
	settings_tab.exit_button.button_down.connect(on_exit_pressed)

func on_exit_pressed() -> void:
	emit_signal("exit_options_menu")
