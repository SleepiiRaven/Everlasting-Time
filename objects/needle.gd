extends StaticBody2D


func _ready():
	if (GlobalSettings.amber_carrying_needle):
		queue_free()
