extends Area2D

var pickup = false
var active = false
@onready var particles = $Particles
@onready var coolantArea = $Coolant/CollisionShape2D

var spawnPos = Vector2(0,0)

func _ready():
	coolantArea.disabled = true
	spawnPos = global_position

func _process(delta):
	if pickup:
		global_position = get_global_mouse_position().snapped(Vector2(1,1))
	if active:
		rotation_degrees = lerp(rotation_degrees, 105.0, delta * 10)
		if rotation_degrees > 90.0:
			particles.emitting = true
			coolantArea.disabled = false
		else:
			particles.emitting = false
			coolantArea.disabled = true
	elif !is_zero_approx(rotation_degrees):
		rotation_degrees = lerp(rotation_degrees, 0.0, delta * 10)
		if rotation_degrees > 90.0:
			particles.emitting = true
			coolantArea.disabled = false
		else:
			particles.emitting = false
			coolantArea.disabled = true

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('click'):
		pickup = true
	if event.is_action_released('click'):
		pickup = false
		active = false
		rotation_degrees = 0
		particles.emitting = false
		global_position = spawnPos
	if event.is_action_pressed("rclick") and pickup:
		active = true
	if event.is_action_released("rclick") and pickup:
		active = false
