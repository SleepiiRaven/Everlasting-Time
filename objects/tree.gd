extends Sprite2D

@export var day = preload("res://art/tree_day.png")
@export var night = preload("res://art/tree_night.png")

func _ready():
	if (GlobalSettings.is_day):
		texture = day
	else:
		texture = night

func _physics_process(delta):
	if (GlobalSettings.is_day):
		if (texture == day): return;
		texture = day
	else:
		if (texture == night): return;
		texture = night
