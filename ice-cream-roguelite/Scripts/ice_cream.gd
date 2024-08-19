extends Area2D

var pickup = false

var freezerTexture = preload("res://assets/truck/icecreamsheet2.png")
var normalTexture = preload("res://assets/truck/icecreamsheet1.png")

var inFreezer = false
var atCustomer = false

var spawnIndex = 0
var iceCreamType = 0
var freezer = null

var main

@onready var sprite = $Sprite2D
@onready var button = $Button

func _ready():
	sprite.texture = freezerTexture
	sprite.frame = iceCreamType
	visible = false

func _process(delta):
	if pickup:
		global_position = get_global_mouse_position()

func _on_area_entered(area):
	if area.is_in_group("freezer"):
		inFreezer = true
		if !pickup:
			z_index = 0
			sprite.texture = freezerTexture
		visible = true
	if area.is_in_group("customer"):
		atCustomer = true
func _on_area_exited(area):
	if area.is_in_group("freezer"):
		inFreezer = false
		if !pickup:
			visible = false
	if area.is_in_group("customer"):
		atCustomer = false


func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		startPickup()
	if event.is_action_released("click") and pickup:
		main.grabbingItem = false
		if atCustomer and main.activeCustomer:
			giveToCustomer()
		else:
			stopPickupFreezer()

func startPickup() -> void:
	if main.grabbingItem == false:
		pickup = true
		z_index = 2
		sprite.texture = normalTexture
		freezer.removeIceCream(spawnIndex)
		main.grabbingItem = true

func stopPickupFreezer() -> void:
	freezer.addIceCream(spawnIndex)
	queue_free()

func giveToCustomer() -> void:
	if main.currentOffer[0][iceCreamType] > 0:
		main.giveIceCream(iceCreamType)
		queue_free()
	else:
		stopPickupFreezer()
