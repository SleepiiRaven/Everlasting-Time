extends StaticBody2D

@export var day = preload("res://art/tree_day.png")
@export var night = preload("res://art/tree_night.png")

func _ready():
	if (GlobalSettings.is_day):
		$Sprite2D.texture = day
	else:
		$Sprite2D.texture = night

func _physics_process(delta):
	if (GlobalSettings.is_day):
		if ($Sprite2D.texture == day): return;
		$Sprite2D.texture = day
	else:
		if ($Sprite2D.texture == night): return;
		$Sprite2D.texture = night
