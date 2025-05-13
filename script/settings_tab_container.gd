extends Control

@onready var exit_button = $Panel/ScrollContainer/MarginContainer/VBoxContainer/Exit_Button

signal exit_options_menu

func _ready():
	exit_button.button_down.connect(func(): emit_signal("exit_options_menu"))



#extends Control
#
#const SETTINGS_FILE_PATH = "user://settings.cfg"
#
#@onready var exit_button = $Panel/ScrollContainer/MarginContainer/VBoxContainer/Exit_Button
#@onready var window_mode_button = $Panel/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainerGraphics/GraphicsMarginContainer/VBoxContainer/Window_Mode_Button
#@onready var resolution_mode_button = $Panel/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainerGraphics/GraphicsMarginContainer/VBoxContainer/Resolution_Mode_Button
#@onready var controls_margin_container = $Panel/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainerControls/ControlsMarginContainer
#@onready var sound_margin_container = $Panel/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/SoundMarginContainer
#
#signal exit_options_menu
#
#func _ready():
	#load_settings()
	#exit_button.button_down.connect(func(): emit_signal("exit_options_menu"))
#
## Save all settings to the config file
#func save_settings():
	#var config = ConfigFile.new()
#
	## Save graphics settings (Resolution)
	#config.set_value("Graphics", "resolution", window_mode_button.option_button.selected)
#
	## Save graphics settings (Window Mode)
	#config.set_value("Graphics", "window_mode", resolution_mode_button.option_button.selected)
#
	## Save sound settings
	#config.set_value("Sound", "master_volume", sound_margin_container.h_slider.value)
	#config.set_value("Sound", "music_volume", sound_margin_container.h_slider.value)
	#config.set_value("Sound", "sfx_volume", sound_margin_container.h_slider.value)
#
	#for child in sound_margin_container.get_children():
		#if child is Audio_Slider_Settings:
			#var action_name = child.action_name
			#var event = InputMap.action_get_events(action_name)[0]
			#if event is InputEventKey:
				#config.set_value("Controls", action_name, event.keycode)
			#elif event is InputEventMouseButton:
				#config.set_value("Controls", action_name, event.button_index)
#
	## Save control settings
	#for child in controls_margin_container.get_children():
		#if child is HotkeyRebindButton:
			#var action_name = child.action_name
			#var event = InputMap.action_get_events(action_name)[0]
			#if event is InputEventKey:
				#config.set_value("Controls", action_name, event.keycode)
			#elif event is InputEventMouseButton:
				#config.set_value("Controls", action_name, event.button_index)
#
	## Save the config file
	#config.save(SETTINGS_FILE_PATH)
	#print("Settings saved to:", SETTINGS_FILE_PATH)
#
## Load all settings from the config file
#func load_settings():
	#var config = ConfigFile.new()
#
	## Load the config file
	#var err = config.load(SETTINGS_FILE_PATH)
	#if err != OK:
		#print("No settings file found. Using default settings.")
		#return
#
	## Load graphics settings (Resolution)
	#var resolution_index = config.get_value("Graphics", "resolution", 0)
	#graphics_tab_1.option_button.select(resolution_index)
	#graphics_tab_1.on_resolution_selected(resolution_index)
#
	## Load graphics settings (Window Mode)
	#var window_mode_index = config.get_value("Graphics", "window_mode", 0)
	#graphics_tab_2.option_button.select(window_mode_index)
	#graphics_tab_2.on_window_mode_selected(window_mode_index)
#
	## Load sound settings
	#sound_tab.h_slider.value = config.get_value("Sound", "master_volume", 1.0)
	#sound_tab.on_value_changed(sound_tab.h_slider.value)
#
	## Load control settings
	#for child in controls_margin_container.get_children():
		#if child is HotkeyRebindButton:
			#var action_name = child.action_name
			#var keycode_or_button = config.get_value("Controls", action_name, null)
			#if keycode_or_button != null:
				#var event = InputEventKey.new() if keycode_or_button < 1000 else InputEventMouseButton.new()
				#if event is InputEventKey:
					#event.keycode = keycode_or_button
				#elif event is InputEventMouseButton:
					#event.button_index = keycode_or_button
				#InputMap.action_erase_events(action_name)
				#InputMap.action_add_event(action_name, event)
				#child.update_button_text()
#
	#print("Settings loaded from:", SETTINGS_FILE_PATH)
#
## Save settings when the Apply button is pressed
#func _on_apply_button_pressed():
	#save_settings()
	#print("Settings applied and saved.")
