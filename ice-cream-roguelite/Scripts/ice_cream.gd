extends Area2D

var pickup = false
var targetPos

var freezerTexture
var normalTexture

var inFreezer = false

@onready var sprite = $Sprite2D

func _ready():
	targetPos = global_position
	sprite.texture = freezerTexture

func _process(delta):
	if global_position.distance_to(targetPos) > 1:
		global_position = global_position.lerp(targetPos, delta * 10)
	if pickup:
		targetPos = get_global_mouse_position()

func _on_button_button_down():
	pickup = true
	z_index = 2
	sprite.texture = normalTexture

func _on_button_button_up():
	pickup = false
	if inFreezer:
		z_index = 0
		sprite.texture = freezerTexture


func _on_area_entered(area):
	if area.is_in_group("freezer"):
		inFreezer = true


func _on_area_exited(area):
	if area.is_in_group("freezer"):
		inFreezer = false
