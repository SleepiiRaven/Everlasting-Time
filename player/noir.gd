extends CharacterBody2D

signal changed_time

@export var max_speed = 150
@export var acceleration = 500
@export var friction = 800

var direction = Vector2.DOWN
var current_velocity = Vector2.ZERO
var animating = false
var talking = false
var changing_time = false
var opening = null

var without_spool = preload("res://player/noir.tres")
var with_spool = preload("res://player/noir_spool.tres")
var threaded_needle = preload("res://objects/threaded_needle.tscn")
var dialog_box = preload("res://objects/noir_dialog_box.tscn")
var opened_door = preload("res://objects/time_gate_open.tscn")

@onready var sprite = $Sprite

func _ready():
	if (GlobalSettings.noir_carrying_spool):
		sprite.sprite_frames = with_spool
	else:
		sprite.sprite_frames = without_spool

func _physics_process(delta: float):
	if (get_node_or_null("GUI/NoirDialogBox") == null):
		talking = false
		if (opening != null):
			var door_instance = opened_door.instantiate()
			door_instance.global_position = opening.global_position
			opening.add_sibling(door_instance)
			opening.queue_free()
			
	if (!GlobalSettings.is_day && !animating && !talking && !changing_time):
		move()
		if (Input.is_action_just_pressed("interact")):
			interact()
	elif (!animating):
		animate_player(Vector2.ZERO)

func move():
	var input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	animate_player(input_vector)
	if input_vector != Vector2.ZERO:
		current_velocity = current_velocity.move_toward(input_vector * max_speed, acceleration * get_physics_process_delta_time())
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * get_physics_process_delta_time())
	velocity = current_velocity
	move_and_slide()

func trigger_dialog(dialog_path: String):
	var dialog_box_instance = dialog_box.instantiate()
	dialog_box_instance.dialogPath = dialog_path
	await get_tree().create_timer(0.05).timeout
	$GUI.add_child(dialog_box_instance)
	talking = true

func interact():
	if ($Interact.is_colliding()):
		var colliding = $Interact.get_collider()
		if (colliding.is_in_group("player") && colliding.get_name() != "Noir"):
			trigger_dialog("res://dialog/noir_interact_frozen.json")
		elif (colliding.is_in_group("needle")):
			if (GlobalSettings.noir_carrying_spool):
				$ThreadNeedle.play()
				animating = true
				match direction:
					Vector2.UP:
						sprite.play("thread_up")
					Vector2.DOWN:
						sprite.play("thread_down")
					Vector2.LEFT:
						sprite.play("thread_left")
					Vector2.RIGHT:
						sprite.play("thread_right")
				await get_tree().create_timer(1.4).timeout
				animating = false
				GlobalSettings.needle_threaded = true
				var needle_instance = threaded_needle.instantiate()
				needle_instance.position = colliding.position
				colliding.add_sibling(needle_instance)
				colliding.free()
				trigger_dialog("res://dialog/noir_thread_needle_first_time.json")
			else:
				trigger_dialog("res://dialog/noir_interact_needle_first_time.json")
		elif (colliding.is_in_group("threaded_needle")):
			trigger_dialog("res://dialog/noir_interact_threaded_needle.json")
		elif (colliding.is_in_group("spool")):
			if (!GlobalSettings.collected_spool):
				trigger_dialog("res://dialog/noir_interact_spool.json")
			colliding.free()
			$PickUpSpool.play()
			sprite.sprite_frames = with_spool
			GlobalSettings.noir_carrying_spool = true
			GlobalSettings.collected_spool = true
		elif (colliding.is_in_group("clock")):
			emit_signal("changed_time")
			changing_time = true
			await get_tree().create_timer(1.1).timeout
			changing_time = false
		elif (colliding.is_in_group("time_pillar")):
			if (GlobalSettings.beat_thread_puzzle_of_room):
				trigger_dialog("res://dialog/noir_interact_beat_puzzle.json")
			else:
				trigger_dialog("res://dialog/noir_interact_time_pillar.json")
		elif (colliding.is_in_group("time_gate")):
			if (GlobalSettings.beat_thread_puzzle_of_room):
				trigger_dialog("res://dialog/noir_interact_gate_puzzle_solved.json")
				await get_tree().create_timer(0.05).timeout
				opening = colliding
			else:
				trigger_dialog("res://dialog/noir_interact_gate.json")
		elif (colliding.is_in_group("loom")):
			trigger_dialog("res://dialog/noir_interact_loom.json")
				
func animate_player(input: Vector2):
	if input != Vector2.ZERO:
		if input.y < 0:
			sprite.play("walk_up")
			direction = Vector2.UP
			$Interact.rotation_degrees = 180
		elif input.y > 0:
			sprite.play("walk_down")
			direction = Vector2.DOWN
			$Interact.rotation_degrees = 0
		elif input.x < 0:
			sprite.play("walk_left")
			direction = Vector2.LEFT
			$Interact.rotation_degrees = 90
		elif input.x > 0:
			sprite.play("walk_right")
			direction = Vector2.RIGHT
			$Interact.rotation_degrees = 270
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
