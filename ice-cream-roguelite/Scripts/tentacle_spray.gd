extends Area2D

var pickup = false
var spawnPos = Vector2(0,0)

var particles = preload("res://Scenes/spray_particles.tscn")
@onready var particleParent = $Particles
@onready var area = $TentacleBeGone/CollisionShape2D
@onready var pickupSound = $pickup

func _ready():
	spawnPos = global_position

func _process(delta):
	if pickup:
		global_position = get_global_mouse_position().snapped(Vector2(1,1))


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed('click') and !pickup:
		pickup = true
		pickupSound.play()
	if event.is_action_released('click') and pickup:
		pickup = false
		global_position = spawnPos
	if event.is_action_pressed('rclick') and pickup:
		var newParticles = particles.instantiate()
		#newParticles.global_position = particleParent.global_position
		particleParent.add_child(newParticles)
		area.disabled = false
		await get_tree().create_timer(0.05).timeout
		area.disabled = true

func spray() -> void:
	pass
