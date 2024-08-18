extends Control

var sprite = null
var num = 0

@onready var numberDisplay = $Label
@onready var image = $Sprite2D

func _ready():
	numberDisplay.text = "x" + str(num)
	image.texture = sprite
