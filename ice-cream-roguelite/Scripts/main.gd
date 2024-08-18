extends Node2D

@onready var customerAnimation = $Customer/AnimationPlayer
@onready var UI = $UI
@onready var UIiceCreamsContainer = $"UI/Ice Creams/VBoxContainer"
@onready var UIaskingPrice = $UI/Money/Label

var iceCreamDisplay = preload("res://Scenes/UI/CustomerIceCreamDisplay.tscn")

@export var iceCreamData = {
	0 : [preload("res://Programmer Art/iceCream1.png"), 1.25],
	1 : [preload("res://Programmer Art/iceCream1.png"), 2.50],
	2 : [preload("res://Programmer Art/iceCream1.png"), 2.0]
}
@export var maxGreed = 1.0
@export var priceVariation = [-0.50, 0.50]
@export var maxIceCreams = 5
@export var maxSoloIceCream = 3

var currentOffer
var activeCustomer = false

func _ready():
	newCustomer()

#CUSTOMER LOGIC
func newCustomer() -> void:
	var cones = generateCones()
	var price = generatePrice(cones)
	currentOffer = [cones, price]
	customerAnimation.play("CustomerEnter")
	setUI(cones, price)
	await get_tree().create_timer(0.7).timeout
	activeCustomer = true
func setUI(cones, price) -> void:
	for c in UIiceCreamsContainer.get_children():
		c.queue_free()
	var index = 0
	for i in cones:
		if i != 0:
			var newIceCreamDisplay = iceCreamDisplay.instantiate()
			newIceCreamDisplay.num = i
			newIceCreamDisplay.sprite = iceCreamData[index][0]
			UIiceCreamsContainer.add_child(newIceCreamDisplay)
		index += 1
	UIaskingPrice.text = "$" + ("%0.2f" % price)
	await get_tree().create_timer(0.5).timeout
	UI.visible = true
func generateCones() -> Array:
	var cont = false
	var cones
	while !cont:
		cones = [randi_range(0,maxSoloIceCream), randi_range(0,maxSoloIceCream), randi_range(0,maxSoloIceCream)]
		var coneTotal = cones[0] + cones[1] + cones[2]
		if coneTotal <= maxIceCreams and coneTotal > 0:
			cont = true
	return cones
func generatePrice(cones) -> float:
	var greed = randf_range(0, maxGreed)
	var index = 0
	var price = 0
	for c in cones:
		var greedPrice = iceCreamData[index][1] - greed
		for i in c:
			price += (greedPrice + randf_range(priceVariation[0], priceVariation[1]))
		index += 1
	price = snappedf(price, 0.25)
	return price
#END CUSTOMER LOGIC

func _on_bell_pressed():
	if activeCustomer:
		acceptOffer()
		customerLeave()
func acceptOffer() -> void:
	pass #code will go here when other systems are in

func _on_x_pressed():
	if activeCustomer:
		rejectOffer()
		customerLeave()
func rejectOffer() -> void:
	pass #code will go here when other systems are in

func customerLeave() -> void:
	activeCustomer = false
	UI.visible = false
	customerAnimation.play("CustomerLeave")
	await get_tree().create_timer(0.5).timeout
	customerAnimation.play("CustomerEnter")
	newCustomer()
