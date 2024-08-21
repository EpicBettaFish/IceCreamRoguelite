extends GPUParticles2D


func _ready():
	emitting = true
	print(emitting)


func _on_finished():
	queue_free()
