extends Control

var sprite = null
var num = 0
var fulfilled = 0

@onready var numberDisplay = $Label
@onready var image = $Sprite2D
@onready var check = $Check

func _ready():
	check.visible = false
	numberDisplay.text = "x" + str(num)
	image.texture = sprite

func updateValue(value):
	fulfilled += 1
	check.visible = false
	numberDisplay.text = "x" + str(num) + "(" + str(fulfilled) + ")"
	image.texture = sprite
	if value == 0:
		check.visible = true
