extends CharacterBody2D

# Signal variables.
signal changed_time

# Exported variables. These will show up in the editor, and you can change them on an instance-by-instance basis.
@export var max_speed = 150
@export var acceleration = 500
@export var friction = 800

# General variables.
var direction = Vector2.DOWN
var current_velocity = Vector2.ZERO
var connected = null
var talking = false
var changing_time = false
var beating_level = false
var puzzle_order = []

# Scenes
var needle = preload("res://objects/needle.tscn")
var without_needle = preload("res://player/amber.tres")
var with_needle = preload("res://player/amber_needle.tres")
var rope = preload("res://objects/rope.tscn")
var dialog_box = preload("res://objects/amber_dialog_box.tscn")

# Variables that get declared on the ready function. Just a quicker way and don't need 2 lines to do this.
@onready var sprite = $Sprite

func _ready():
	if (GlobalSettings.amber_carrying_needle):
		sprite.sprite_frames = with_needle
	else:
		sprite.sprite_frames = without_needle

func _physics_process(delta: float):
	if ($Rope.visible && connected != null):
		update_rope(connected.global_position)
	if (get_node_or_null("GUI/AmberDialogBox") == null):
		talking = false
		if (beating_level):
			SceneTransition.change_scene(GlobalSettings.next_level)
	if (GlobalSettings.is_day && !talking && !changing_time):
		move()
		if (Input.is_action_just_pressed("interact")):
			interact()
	else:
		animate_player(Vector2.ZERO)
	
func animate_player(input: Vector2):
	if input != Vector2.ZERO:
		if input.y < 0:
			sprite.play("walk_up")
			direction = Vector2.UP
			$Interact.rotation_degrees = 180
			$Node2D.position = Vector2(4, -18)
		elif input.y > 0:
			sprite.play("walk_down")
			direction = Vector2.DOWN
			$Interact.rotation_degrees = 0
			$Node2D.position = Vector2(-6, -18)
		elif input.x < 0:
			sprite.play("walk_left")
			direction = Vector2.LEFT
			$Interact.rotation_degrees = 90
			$Node2D.position = Vector2(6, -19)
		elif input.x > 0:
			sprite.play("walk_right")
			direction = Vector2.RIGHT
			$Interact.rotation_degrees = 270
			$Node2D.position = Vector2(-3, -17)
	else:
		match direction:
			Vector2.UP:
				sprite.play("idle_up")
			Vector2.DOWN:
				sprite.play("idle_down")
			Vector2.LEFT:
				sprite.play("idle_left")
			Vector2.RIGHT:
				sprite.play("idle_right")

func trigger_dialog(dialog_path: String):
	var dialog_box_instance = dialog_box.instantiate()
	dialog_box_instance.dialogPath = dialog_path
	await get_tree().create_timer(0.05).timeout
	$GUI.add_child(dialog_box_instance)
	talking = true

func interact():
	if ($Interact.is_colliding()):
		var colliding = $Interact.get_collider()
		if (colliding.is_in_group("player") && colliding.get_name() != "Amber"):
			trigger_dialog("res://dialog/amber_interact_frozen.json")
		elif (colliding.is_in_group("needle")):
			if (!GlobalSettings.collected_needle):
				trigger_dialog("res://dialog/amber_interact_needle_first_time.json")
			colliding.free()
			$PickUpNeedle.play()
			sprite.sprite_frames = with_needle
			GlobalSettings.amber_carrying_needle = true
			GlobalSettings.collected_needle = true
		elif (colliding.is_in_group("threaded_needle")):
			if (!GlobalSettings.collected_threaded_needle):
				trigger_dialog("res://dialog/amber_interact_needle_threaded_first_time.json")
			colliding.free()
			$PickUpNeedle.play()
			sprite.sprite_frames = with_needle
			GlobalSettings.amber_carrying_needle = true
			GlobalSettings.collected_needle = true
			GlobalSettings.collected_threaded_needle = true
		elif (colliding.is_in_group("time_pillar")):
			if (!colliding.threaded && GlobalSettings.amber_carrying_needle):
				if (GlobalSettings.needle_threaded):
					$ThreadTimePillar.play()
					colliding.threaded = true
					GlobalSettings.time_pillars_unlocked += 1
					puzzle_order.append(colliding)
					if (connected != null):
						var rope_instance = rope.instantiate()
						rope_instance.points = [connected.global_position, colliding.global_position]
						add_sibling(rope_instance)
					if (GlobalSettings.time_pillars_unlocked >= GlobalSettings.time_pillars_total):
						for solution in GlobalSettings.puzzle_solutions:
							if (puzzle_order == solution):
								trigger_dialog("res://dialog/amber_beat_puzzle.json")
								GlobalSettings.beat_thread_puzzle_of_room = true
						if (GlobalSettings.beat_thread_puzzle_of_room == false):
							trigger_dialog("res://dialog/amber_lose_puzzle.json")
						$Rope.visible = false
						return
					update_rope(colliding.global_position)
					$Rope.visible = true
					connected = colliding
				else:
					trigger_dialog("res://dialog/amber_try_thread_time_pillar_no_thread.json")
			elif (colliding.threaded && GlobalSettings.amber_carrying_needle):
				trigger_dialog("res://dialog/amber_interact_time_pillar_threaded.json")
		elif (colliding.is_in_group("spool")):
			trigger_dialog("res://dialog/amber_interact_spool.json")
		elif (colliding.is_in_group("clock")):
			emit_signal("changed_time")
			changing_time = true
			await get_tree().create_timer(1.1).timeout
			changing_time = false
		elif (colliding.is_in_group("time_gate")):
			trigger_dialog("res://dialog/amber_interact_gate.json")
		elif (colliding.is_in_group("loom")):
			trigger_dialog("res://dialog/amber_interact_loom.json")
			await get_tree().create_timer(0.05).timeout
			beating_level = true
	elif (GlobalSettings.amber_carrying_needle):
		GlobalSettings.amber_carrying_needle = false
		var needle_instance = needle.instantiate()
		needle_instance.global_position = global_position + (direction * 30)
		add_sibling(needle_instance)
		$PlaceNeedle.play()
		sprite.sprite_frames = without_needle

func move():
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	animate_player(input_vector)
	if input_vector != Vector2.ZERO:
		current_velocity = current_velocity.move_toward(input_vector * max_speed, acceleration * get_physics_process_delta_time())
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * get_physics_process_delta_time())
	velocity = current_velocity
	move_and_slide()

func update_rope(other_end_pos: Vector2) -> void:
	$Rope.points = [$Node2D.position, other_end_pos - global_position]
