extends Node2D

@onready var customerAnimation = $SubViewport/Customer/AnimationPlayer
@onready var customerSprite = $SubViewport/Customer
@onready var UI = $SubViewport/UI
@onready var UIiceCreamsContainer = $"SubViewport/UI/Ice Creams/VBoxContainer"
@onready var UIaskingPrice = $SubViewport/UI/Money/Label

@onready var mainTimer = $SubViewport/PrimaryTimer
@onready var secondaryTimer = $SubViewport/SecondaryTimer

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

var currentMoney: float = 0.00
var soulCoins: int = 0

var registerOpen = false
@onready var openRegisterSprite = $Interactable/Register/OpenRegister
@onready var registerMoneyCounter = $"Interactable/Register/Skew/Dollar Counter"
@onready var dollarDetector = $Interactable/Register/DollarDetector/CollisionPolygon2D

@onready var registerCoinCounter = $"Interactable/InsertCoin/Coin Counter"
@onready var coinSpawn = $CoinSpawnPos
var coinScene = preload("res://Scenes/soulCoin.tscn")

var activeMoney = null
var activeCoin = null

var timerActive = false
var timerTimeRecover = false
var timerTimeTarget: float = 0.0
@export var timerMaxTime: float = 20.0
var timeRemaining: float = 100.0
@export var soulTime: float = 2.0
@export var regenTime : float = 0.5

var moneyScene = preload("res://Scenes/money.tscn")
@onready var moneySpawn = $MoneySpawnPos
@onready var items = $Items

@export var customerSprites: Array

@export var testingMode: bool = false

var inventory = [100,100,100]

var grabbingItem = false

@onready var dialogueUI = $SubViewport/DialogueUI
@onready var dialoguePanel = $SubViewport/DialogueUI/PanelContainer
@onready var dialogueText = $SubViewport/DialogueUI/PanelContainer/RichTextLabel
@export var dialogueOptions: Array
@onready var dialogueAnim = $SubViewport/DialogueUI/AnimationPlayer
@onready var dialogueTimer = $SubViewport/DialogueUI/DialogueTimer
var canContinueDialogue = false
var dialogueActive = false
var skipDialogue = false
var previousDialogue = null
var dialogueTimerTimeRemaining = 3.0
var dialogueTimerCountdown = false
@onready var continueDialogue = $ContinueDialogue/CollisionShape2D

@export var tentacleHits = 15

var coolantSpeed = 1
var coolantActive = false
var freezers = []
@onready var coolantNode = $Items/Coolant

func _ready():
	newCustomer()
	registerCoinCounter.text = ("%03d" % soulCoins)
	registerMoneyCounter.text = ("%0.2f" % currentMoney)
	dialogueUI.visible = false
	mainTimer.value = 0
	secondaryTimer.value = 0
	continueDialogue.disabled = true
	coolantNode.remainingCoolant = Singleton.equipment.coolant[2]
	match Singleton.equipment.coolant[0]:
		true:
			coolantNode.type = 1
		false:
			coolantNode.type = 0
	$"TESTING BUTTONS".visible = testingMode
	loadEquipment()

func _process(delta):
	if timerActive:
		if timerTimeRecover:
			timeRemaining = lerp(timeRemaining, timerTimeTarget, delta * 10)
			if abs(timerTimeTarget - timeRemaining) < 0.1:
				timerTimeRecover = false
				timeRemaining = timerTimeTarget
		elif activeCustomer:
			timeRemaining -= delta
		if timeRemaining < timerMaxTime - soulTime:
			mainTimer.value = timeRemaining
		else:
			mainTimer.value = timerMaxTime - soulTime
		secondaryTimer.value = timeRemaining
		if timeRemaining <= 0:
			rejectOffer()
			customerLeave()
	if dialogueTimerCountdown:
		dialogueTimerTimeRemaining -= delta
		dialogueTimer.value = dialogueTimerTimeRemaining
		if dialogueTimerTimeRemaining <= 0:
			dialogueTimerCountdown = false
			canContinueDialogue = false
			dialogueAnim.play("RESET")
			startOrder()

#CUSTOMER LOGIC
func newCustomer() -> void:
	var cones = generateCones()
	var price = generatePrice(cones)
	currentOffer = [cones, price]
	customerAnimation.play("CustomerEnter")
	customerSprite.texture = customerSprites.pick_random()
	setUI(cones, price)
	var willPlayDialogue = randi_range(1,5)
	await get_tree().create_timer(0.5).timeout
	if willPlayDialogue == 1:
		playDialogue()
	else:
		startOrder()

func startOrder() -> void:
	dialogueUI.visible = false
	setTimers()
	UI.visible = true
	activeCustomer = true

func playDialogue() -> void:
	dialogueActive = true
	var cont = false
	var currentDialogue
	while !cont:
		currentDialogue = dialogueOptions.pick_random()
		if currentDialogue != previousDialogue:
			cont = true
	previousDialogue = currentDialogue
	dialogueUI.visible = true
	var finalDialogue = currentDialogue.replace("|","")
	dialogueText.text = finalDialogue
	dialogueText.visible_ratio = 0
	var bbCode = false
	continueDialogue.disabled = false
	for i in currentDialogue:
		if skipDialogue:
			dialogueAnim.play("continuePopout")
			skipDialogue = false
			canContinueDialogue = true
			dialogueActive = false
			dialogueTimer.value = 3
			dialogueText.visible_ratio = 1
			await get_tree().create_timer(0.4).timeout
			dialogueTimerTimeRemaining = 3.0
			dialogueTimerCountdown = true
			continueDialogue.disabled = false
			return
		match i:
			"|":
				await get_tree().create_timer(0.25).timeout
			"[":
				bbCode = true
			"]":
				bbCode = false
			_:
				if !bbCode:
					dialogueText.visible_characters += 1
					match i:
						",":
							await get_tree().create_timer(0.1).timeout
						".":
							await get_tree().create_timer(0.5).timeout
						_:
							await get_tree().create_timer(0.03).timeout
	dialogueAnim.play("continuePopout")
	canContinueDialogue = true
	dialogueActive = false
	dialogueTimer.value = 3
	await get_tree().create_timer(0.4).timeout
	dialogueTimerTimeRemaining = 3.0
	dialogueTimerCountdown = true
	continueDialogue.disabled = false

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

func setTimers() -> void:
	timeRemaining = timerMaxTime
	mainTimer.max_value = timeRemaining
	mainTimer.value = timeRemaining - soulTime
	secondaryTimer.max_value = timeRemaining
	secondaryTimer.value = timeRemaining
	timerActive = true
#END CUSTOMER LOGIC

func acceptOffer() -> void:
	createMoney()
	if timeRemaining >= timerMaxTime - soulTime:
		createCoin()

func createMoney() -> void:
	if activeMoney == null:
		var newMoney = moneyScene.instantiate()
		newMoney.global_position = moneySpawn.global_position
		newMoney.value = currentOffer[1]
		newMoney.main = self
		items.add_child(newMoney)
		activeMoney = newMoney
	else:
		activeMoney.value += currentOffer[1]
func createCoin() -> void:
	if activeCoin == null:
		var newCoin = coinScene.instantiate()
		newCoin.global_position = coinSpawn.global_position
		newCoin.value = 1
		newCoin.main = self
		items.add_child(newCoin)
		activeCoin = newCoin
	else:
		activeCoin.value += 1

func collectMoney(value, type) -> void:
	if type == false:
		currentMoney += value
		registerMoneyCounter.text = ("%0.2f" % currentMoney)
		activeMoney = null
	else:
		soulCoins += value
		registerCoinCounter.text = ("%03d" % soulCoins)
		activeCoin = null

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
	timerTimeRecover = true
	timerTimeTarget = timerMaxTime
	await get_tree().create_timer(0.5).timeout
	customerAnimation.play("CustomerEnter")
	newCustomer()

func giveIceCream(iceCreamID) -> void:
	currentOffer[0][iceCreamID] -= 1
	activeUINodes[iceCreamID].updateValue(currentOffer[0][iceCreamID])
	timerTimeRecover = true
	timerTimeTarget = timeRemaining + regenTime
	if currentOffer[0] == [0,0,0]:
		acceptOffer()
		customerLeave()

func _on_testing_pass_pressed():
	acceptOffer()
	customerLeave()
func _on_testing_fail_pressed():
	rejectOffer()
	customerLeave()

func _on_register_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		registerOpen = !registerOpen
		openRegisterSprite.visible = registerOpen
		dollarDetector.disabled = !registerOpen


func _on_continue_dialogue_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		if canContinueDialogue:
			dialogueTimerCountdown = false
			canContinueDialogue = false
			continueDialogue.disabled = true
			dialogueAnim.play("RESET")
			startOrder()
		elif dialogueActive:
			skipDialogue = true


func loadEquipment() -> void:
	coolantSpeed = Singleton.equipment.coolant[1]


func _on_coolant_hole_area_entered(area):
	if area.is_in_group("coolant"):
		await get_tree().create_timer(0.7).timeout
		coolantActive = true
		for i in freezers:
			i.coolantStart()
func _on_coolant_hole_area_exited(area):
	if area.is_in_group("coolant"):
		await get_tree().create_timer(0.7).timeout
		coolantActive = false
		for i in freezers:
			i.coolantEnd()
