extends Node2D

signal changed

# Called when the node enters the scene tree for the first time.
func _ready():
	GlobalSettings.time_pillars_total = 4
	var time_pillar_1 = $YSort/Puzzles/TimePillar
	var time_pillar_2 = $YSort/Puzzles/TimePillar2
	var time_pillar_3 = $YSort/Puzzles/TimePillar3
	var time_pillar_4 = $YSort/Puzzles/TimePillar4

	GlobalSettings.puzzle_solutions.append([time_pillar_1, time_pillar_2, time_pillar_4, time_pillar_3])
	GlobalSettings.puzzle_solutions.append([time_pillar_1, time_pillar_3, time_pillar_4, time_pillar_2])
	GlobalSettings.puzzle_solutions.append([time_pillar_2, time_pillar_1, time_pillar_3, time_pillar_4])
	GlobalSettings.puzzle_solutions.append([time_pillar_2, time_pillar_4, time_pillar_3, time_pillar_1])
	GlobalSettings.puzzle_solutions.append([time_pillar_3, time_pillar_1, time_pillar_2, time_pillar_4])
	GlobalSettings.puzzle_solutions.append([time_pillar_3, time_pillar_4, time_pillar_2, time_pillar_1])
	GlobalSettings.puzzle_solutions.append([time_pillar_4, time_pillar_2, time_pillar_1, time_pillar_3])
	GlobalSettings.puzzle_solutions.append([time_pillar_4, time_pillar_3, time_pillar_1, time_pillar_2])
	
	GlobalSettings.next_level = "res://level/level_2.tscn"

	emit_signal("changed")
	if (GlobalSettings.is_day):
		$DayTiles.visible = true
		$NightTiles.visible = false
		$YSort/Amber/GUI.visible = true
		$YSort/Noir/GUI.visible = false
		$YSort/Amber/Camera2D.enabled = true
		$YSort/Noir/Camera2D.enabled = false
		$Fade.play("play_day_music")
	else:
		$NightTiles.visible = true
		$DayTiles.visible = false
		$YSort/Amber/GUI.visible = false
		$YSort/Noir/GUI.visible = true
		$YSort/Noir/Camera2D.enabled = true
		$YSort/Amber/Camera2D.enabled = false
		$Fade.play("play_night_music")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("restart")):
		GlobalSettings.amber_carrying_needle = false
		GlobalSettings.noir_carrying_spool = false
		GlobalSettings.needle_threaded = false
		GlobalSettings.beat_thread_puzzle_of_room = false
		GlobalSettings.time_pillars_unlocked = 0
		GlobalSettings.time_pillars_total = 0
		GlobalSettings.puzzle_solutions = []
		$Fade.play("fade_out")
		await get_tree().create_timer(1).timeout
		get_tree().reload_current_scene()

func switch_time():
	emit_signal("changed")
	if (GlobalSettings.is_day):
		$Fade.play("fade_to_night")
	else:
		$Fade.play("fade_to_day")
	await get_tree().create_timer(1).timeout
	$DayTiles.visible = !$DayTiles.visible
	$NightTiles.visible = !$NightTiles.visible
	$YSort/Amber/Camera2D.enabled = !$YSort/Amber/Camera2D.enabled
	$YSort/Noir/Camera2D.enabled = !$YSort/Noir/Camera2D.enabled
	$YSort/Amber/GUI.visible = !$YSort/Amber/GUI.visible
	$YSort/Noir/GUI.visible = !$YSort/Noir/GUI.visible
	GlobalSettings.is_day = !GlobalSettings.is_day


func _on_amber_changed_time():
	switch_time()

func _on_noir_changed_time():
	switch_time()
