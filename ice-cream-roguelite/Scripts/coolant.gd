extends Area2D

var pickup = false
var active = false
@onready var particles = $Particles
@onready var coolantArea = $Coolant/CollisionShape2D

var type = 0
@export var spriteSheets = []

var remainingCoolant = 30

var spawnPos = Vector2(0,0)

func _ready():
	await get_tree().create_timer(0.001).timeout
	coolantArea.disabled = true
	spawnPos = global_position
	$Sprite2D.texture = spriteSheets[type]

func _process(delta):
	print(remainingCoolant)
	if pickup:
		global_position = get_global_mouse_position().snapped(Vector2(1,1))
	if active:
		rotation_degrees = lerp(rotation_degrees, 105.0, delta * 10)
		if rotation_degrees > 90.0 and remainingCoolant > 0:
			remainingCoolant -= delta
			particles.emitting = true
			coolantArea.disabled = false
		else:
			particles.emitting = false
			coolantArea.disabled = true
	elif !is_zero_approx(rotation_degrees):
		rotation_degrees = lerp(rotation_degrees, 0.0, delta * 10)
		if rotation_degrees > 90.0 and remainingCoolant > 0:
			coolantArea.disabled = false
		else:
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
		$Sprite2D.frame = 1
	if event.is_action_pressed("rclick") and pickup:
		active = true
		$Sprite2D.frame = 0
	if event.is_action_released("rclick") and pickup:
		particles.emitting = false
		active = false
		$Sprite2D.frame = 1
