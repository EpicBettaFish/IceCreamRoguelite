extends Area2D

var pickup = false
var spawnPos
var canSlap = true
@onready var anim = $AnimationPlayer

func _ready():
	spawnPos = global_position


func _process(delta):
	if pickup:
		global_position = get_global_mouse_position().snapped(Vector2(1,1))
		rotation_degrees = lerp(rotation_degrees, 180.0, delta * 10)


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('click') and !pickup:
		pickup = true
	if event.is_action_released('click') and pickup:
		pickup = false
		global_position = spawnPos
		rotation_degrees = 0
	if event.is_action_pressed('rclick') and pickup:
		if canSlap:
			anim.play("slap")
			canSlap = false


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slap":
		canSlap = true
