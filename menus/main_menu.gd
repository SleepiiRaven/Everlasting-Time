extends Control

@onready var play_button = $MarginContainer/VBoxContainer/Play
@onready var quit_button = $MarginContainer/VBoxContainer/HBoxContainer/Quit

var next_scene = "res://level/level_1.tscn"

func _on_play_mouse_entered():
	play_button.icon = load("res://art/start_button_h.png")

func _on_play_mouse_exited():
	play_button.icon = load("res://art/start_button.png")

func _on_play_pressed():
	$SFX.play()
	$FadePlayer.play("fade")
	SceneTransition.change_scene(next_scene)
	play_button.icon = load("res://art/start_button_c.png")
	await get_tree().create_timer(0.1).timeout
	play_button.icon = load("res://art/start_button.png")
	await get_tree().create_timer(0.9).timeout
	

func _on_quit_mouse_entered():
	quit_button.icon = load("res://art/quit_button_h.png")

func _on_quit_mouse_exited():
	quit_button.icon = load("res://art/quit_button.png")
	
func _on_quit_pressed():
	$SFX.play()
	$FadePlayer.play("fade")
	quit_button.icon = load("res://art/quit_button_c.png")
	await get_tree().create_timer(0.1).timeout
	quit_button.icon = load("res://art/quit_button.png")
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
