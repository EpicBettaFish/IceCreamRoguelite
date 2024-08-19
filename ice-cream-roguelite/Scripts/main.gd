extends Node2D

@onready var customerAnimation = $Customer/AnimationPlayer
@onready var UI = $UI
@onready var UIiceCreamsContainer = $"UI/Ice Creams/VBoxContainer"
@onready var UIaskingPrice = $UI/Money/Label

var activeUINodes = [null,null,null]

var iceCreamDisplay = preload("res://Scenes/UI/CustomerIceCreamDisplay.tscn")

@export var iceCreamData = {
	0 : [preload("res://Programmer Art/iceCream1.png"), 1.25],
	1 : [preload("res://Programmer Art/iceCream1.png"), 2.50],
	2 : [preload("res://Programmer Art/iceCream1.png"), 2.0]
}

@export var maxIceCreams = 5
@export var maxSoloIceCream = 3

var currentOffer
var activeCustomer = false

var inventory = [100,100,100]

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
	activeUINodes = [null, null, null]
	for c in UIiceCreamsContainer.get_children():
		c.queue_free()
	var index = 0
	for i in cones:
		if i != 0:
			var newIceCreamDisplay = iceCreamDisplay.instantiate()
			newIceCreamDisplay.num = i
			newIceCreamDisplay.sprite = iceCreamData[index][0]
			UIiceCreamsContainer.add_child(newIceCreamDisplay)
			activeUINodes[index] = newIceCreamDisplay
		index += 1
	UIaskingPrice.text = "$" + ("%0.2f" % price)
	await get_tree().create_timer(0.5).timeout
	UI.visible = true
func generateCones() -> Array:
	var cones = []
	var numCones = randi_range(1,maxIceCreams)
	for i in 3:
		var rand = randi_range(0,numCones)
		if i == 2:
			rand = numCones
		cones.append(rand)
		numCones -= rand
	cones.shuffle()
	return cones
func generatePrice(cones) -> float:
	var index = 0
	var price = 0
	for c in cones:
		for i in c:
			price += iceCreamData[index][1]
		index += 1
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

func giveIceCream(iceCreamID) -> void:
	currentOffer[0][iceCreamID] -= 1
	activeUINodes[iceCreamID].updateValue(currentOffer[0][iceCreamID])
	if currentOffer[0] == [0,0,0]:
		acceptOffer()
		customerLeave()
