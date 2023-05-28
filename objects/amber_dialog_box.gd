extends TextureRect

@export var dialogPath = "res://dialog/test.json"
@export var textSpeed = 0.03

var dialog

var neutral = preload("res://art/portraits/amber.png")
var sad = preload("res://art/portraits/amber_sad.png")
var laugh = preload("res://art/portraits/amber_laugh.png")

var phraseNum = 0
var finished = false

func _ready():
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	nextPhrase()

func _process(_delta):
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
		if finished:
			nextPhrase()
		else:
			$Text.visible_characters = len($Text.text)

func getDialog() -> Array:
	var json = load(dialogPath)
	assert(json != null, "Dialog not found")

	var output = json.get_data()

	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []

func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		queue_free()
		return

	finished = false

	$Name.bbcode_text = dialog[phraseNum]["Name"]
	$Text.bbcode_text = dialog[phraseNum]["Text"]

	$Text.visible_characters = 0
	
	$Background.visible = true
	match (dialog[phraseNum]["Emotion"]):
		"Neutral":
			$Background/Character.texture = neutral
		"Sad":
			$Background/Character.texture = sad
		"Laugh":
			$Background/Character.texture = laugh

	while $Text.visible_characters < len($Text.text):
		if ($AudioStreamPlayer.playing == false && $Text.text[$Text.visible_characters] != " "):
			$AudioStreamPlayer.play()
		$Text.visible_characters += 1

		$Timer.start()
		await $Timer.timeout
	
	finished = true
	phraseNum += 1
	return
