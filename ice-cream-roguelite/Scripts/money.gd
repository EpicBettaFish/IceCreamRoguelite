extends Area2D

var pickup = false
var spawn

var value = 0.50

var inRegister = false
var inCoinSlot = false

@export var coin = false
@onready var collider = $CollisionShape2D
@onready var grab = $grab

var occluded = 0

var main

func _ready():
	spawn = global_position

func _process(_delta):
	if pickup:
		global_position = get_global_mouse_position().snapped(Vector2(1,1))


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click") and !pickup:
		startPickup()
		if !coin:
			grab.play()
	if event.is_action_released("click") and pickup:
		if inRegister and !coin:
			collectMoney()
		elif inCoinSlot and coin:
			collectMoney()
		else:
			endPickup()

func startPickup() -> void:
	pickup = true

func collectMoney() -> void:
	main.collectMoney(value, coin)
	queue_free()

func endPickup() -> void:
	global_position = spawn
	pickup = false


func _on_area_entered(area):
	if area.is_in_group("register"):
		inRegister = true
	if area.is_in_group("InsertCoin"):
		inCoinSlot = true
func _on_area_exited(area):
	if area.is_in_group("register"):
		inRegister = false
	if area.is_in_group("InsertCoin"):
		inCoinSlot = false
