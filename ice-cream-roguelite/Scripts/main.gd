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

@onready var registerOpenSound = $Interactable/Register/Open
@onready var registerCloseSound = $Interactable/Register/Close

@export var customerSprites: Array

@export var testingMode: bool = false

var inventory = [1,1,1]

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
@onready var coolantGague = $coolantGague

@onready var tentacleSpray = $Items/TentacleSpray
@onready var flyswatter = $Items/Flyswatter

@export var gremlinSpawns: Array
@onready var gremlin = $Gremlin
@onready var gremlinIceCream = $"Gremlin/GremlinArea/Ice Cream"
@onready var gremlinAnim = $Gremlin/AnimationPlayer
@onready var gremlinSlapSound = $Gremlin/slap
var continueGremlin = false
var chosenCooler
var gremlinHealth = 5
var canRecoverPopsicle = false 

@onready var fog = $Fog
@onready var fogAnim = $Fog/AnimationPlayer
var spawnedFog = false

@onready var fan = $Items/Fan
@onready var fanAnim = $Items/Fan/AnimationPlayer
@onready var fanGague = $Items/Fan/ProgressBar
var fanEnabled = false
var fanBattery = 20

@onready var customerScreenDisplay = $CustomerScreen/CustomerScreenDisplay
@onready var shutterAnim = $shutter/AnimationPlayer
var remainingCustomers = 0

@onready var customerPocket = $CustomerPocket/CollisionShape2D

@onready var closing = $"CustomerScreen/Closing Time"
@onready var dayCounter = $CanvasLayer/ColorRect2/Label

@onready var quotaDisplay = $Skew/Quota

var closingShop = false

var timeSinceMoneyCollection = 0

func _ready():
	inventory = Singleton.inventory
	soulCoins = Singleton.soul_coins
	currentMoney = Singleton.money
	registerCoinCounter.text = ("%03d" % soulCoins)
	registerMoneyCounter.text = ("%0.2f" % currentMoney)
	customerScreenDisplay.text = ("%02d" % Singleton.customerCount[Singleton.day])
	dayCounter.text = "Day " + str(Singleton.day + 1)
	remainingCustomers = Singleton.customerCount[Singleton.day]
	dialogueUI.visible = false
	mainTimer.value = 0
	secondaryTimer.value = 0
	continueDialogue.disabled = true
	$Skew/Quota.text = str("TODAY'S QUOTA: $", Singleton.quota[Singleton.day])
	$"TESTING BUTTONS".visible = testingMode
	await get_tree().create_timer(0.5).timeout
	loadEquipment()
	loadDay()

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
			skipDialogue = false
			continueDialogue.disabled = true
			dialogueAnim.play("RESET")
			startOrder()
	if fanEnabled:
		fanBattery -= delta
		fanGague.value = fanBattery
		if fanBattery <= 0:
			fanEnabled = false
			fanAnim.play("RESET")

#CUSTOMER LOGIC
func newCustomer() -> void:
	if timeSinceMoneyCollection > 3:
		$StealMoneyAnim.play("steal")
		timeSinceMoneyCollection = 0
		activeMoney.queue_free()
		await get_tree().create_timer(1).timeout
	remainingCustomers -= 1
	var cones = generateCones()
	var price = generatePrice(cones)
	currentOffer = [cones, price]
	customerAnimation.play("CustomerEnter")
	customerSprite.texture = customerSprites.pick_random()
	setUI(cones, price)
	var willPlayDialogue = randi_range(1,3)
	await get_tree().create_timer(0.5).timeout
	if willPlayDialogue == 1:
		playDialogue()
	else:
		startOrder()

func startOrder() -> void:
	dialogueUI.visible = false
	customerPocket.disabled = false
	setTimers()
	UI.visible = true
	activeCustomer = true

func playDialogue() -> void:
	dialogueActive = true
	var cont = false
	var currentDialogue
	while !cont:
		var special = randi_range(1, 1000)
		if special == 1:
			currentDialogue = "[rainbow]your mother.[/rainbow]"
		else:
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
							await get_tree().create_timer(0.3).timeout
						_:
							await get_tree().create_timer(0.03).timeout
	if skipDialogue:
		return
	dialogueAnim.play("continuePopout")
	canContinueDialogue = true
	dialogueActive = false
	dialogueTimer.value = 3
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
			newIceCreamDisplay.sprite = index
			UIiceCreamsContainer.add_child(newIceCreamDisplay)
			activeUINodes[index] = newIceCreamDisplay
		index += 1
	UIaskingPrice.text = "$" + ("%0.2f" % price)
	

func generateCones() -> Array:
	var cones = []
	var numCones = -1
	if inventory[0] + inventory[1] + inventory[2] >= maxIceCreams and inventory[0] + inventory[1] + inventory[2] > 0:
		numCones = randi_range(2,maxIceCreams)
	else:
		numCones = randi_range(1,inventory[0] + inventory[1] + inventory[2])
	for i in 3:
		var rand = -1
		rand = randi_range(0,numCones)
		cones.append(rand)
		numCones -= rand
	if cones[0] + cones[1] + cones[2] < numCones:
		var randCone = randi_range(0,2)
		cones[randCone] = numCones
	randomize()
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
	Singleton.customersServed += 1
	if timeRemaining >= timerMaxTime - soulTime:
		createCoin()

func createMoney() -> void:
	timeSinceMoneyCollection += 1
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
		timeSinceMoneyCollection = 0
		currentMoney += value
		registerMoneyCounter.text = ("%0.2f" % currentMoney)
		activeMoney = null
		registerOpen = false
		openRegisterSprite.visible = registerOpen
		dollarDetector.disabled = !registerOpen
		registerCloseSound.play()
		Singleton.totalMoney += value
	else:
		soulCoins += value
		Singleton.totalSoul += value
		registerCoinCounter.text = ("%03d" % soulCoins)
		activeCoin = null

func _on_x_pressed():
	if activeCustomer:
		rejectOffer()
		customerLeave()
func rejectOffer() -> void:
	pass #code will go here when other systems are in

func customerLeave() -> void:
	customerPocket.disabled = true
	activeCustomer = false
	UI.visible = false
	customerScreenDisplay.text = ("%02d" % remainingCustomers)
	customerAnimation.play("CustomerLeave")
	timerTimeRecover = true
	timerTimeTarget = timerMaxTime
	await get_tree().create_timer(0.5).timeout
	if remainingCustomers > 0:
		newCustomer()
	else:
		shutterAnim.play("shutterClose")
		closeShop()

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
		if registerOpen:
			registerOpenSound.play()
		else:
			registerCloseSound.play()


func _on_continue_dialogue_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		if canContinueDialogue:
			dialogueTimerCountdown = false
			canContinueDialogue = false
			skipDialogue = false
			continueDialogue.disabled = true
			dialogueAnim.play("RESET")
			startOrder()
		elif dialogueActive:
			skipDialogue = true
			dialogueAnim.play("continuePopout")
			canContinueDialogue = true
			dialogueActive = false
			dialogueTimer.value = 3


func loadEquipment() -> void:
	coolantNode.remainingCoolant = Singleton.equipment.coolant[2]
	coolantGague.max_value = Singleton.equipment.coolant[2]
	coolantGague.value = Singleton.equipment.coolant[2]
	coolantSpeed = Singleton.equipment.coolant[1]
	match Singleton.equipment.coolant[0]:
		true:
			coolantNode.type = 1
		false:
			coolantNode.type = 0
	
	if !Singleton.equipment.tentaclespray[0]:
		tentacleSpray.free()
	if !Singleton.equipment.flyswatter[0]:
		flyswatter.free()
	if !Singleton.equipment.fan[0]:
		fan.free()


func _on_coolant_hole_area_entered(area):
	if area.is_in_group("coolant"):
		await get_tree().create_timer(1.3).timeout
		coolantActive = true
		for i in freezers:
			i.coolantStart()
func _on_coolant_hole_area_exited(area):
	if area.is_in_group("coolant"):
		await get_tree().create_timer(1.3).timeout
		coolantActive = false
		for i in freezers:
			i.coolantEnd()


func spawnGremlin() -> void:
	gremlinHealth = 5
	var cont = false
	while !cont:
		chosenCooler = randi_range(0,2)
		if freezers[chosenCooler].canClose:
			cont = true
	freezers[chosenCooler].canClose = false
	gremlin.global_position = get_node(gremlinSpawns[chosenCooler]).global_position
	gremlinIceCream.frame = chosenCooler
	var tentacles = freezers[chosenCooler].tentaclesActive
	var overheat = freezers[chosenCooler].overheating
	var hasIceCream
	if tentacles or overheat:
		gremlinAnim.play("failSteal")
		await get_tree().create_timer(1.7).timeout
		freezers[chosenCooler].canClose = true
		freezers[chosenCooler].startIceCreamPickup()
		return
	else:
		if inventory[chosenCooler] == 0:
			hasIceCream = false
			gremlinAnim.play("rummage")
		else:
			gremlinAnim.play("steal")
			hasIceCream = true
		continueGremlin = true
		freezers[chosenCooler].stopIceCreamPickup()
		await get_tree().create_timer(0.7).timeout
		if !continueGremlin:
			return
		freezers[chosenCooler].open()
		await get_tree().create_timer(3).timeout
		if !continueGremlin:
			return
		if hasIceCream:
			freezers[chosenCooler].removeRandomIceCream()
			canRecoverPopsicle = true
		await get_tree().create_timer(0.9).timeout
		if !continueGremlin:
			return
		canRecoverPopsicle = false
		await get_tree().create_timer(1.1).timeout
		if !continueGremlin:
			return
		freezers[chosenCooler].canClose = true
		freezers[chosenCooler].startIceCreamPickup()


func _on_gremlin_area_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		gremlinHealth -= 1
		gremlinSlapSound.play()
		if gremlinHealth <= 0:
			endGremlin()


func _on_gremlin_area_area_entered(area):
	if area.is_in_group("flyswatter"):
		gremlinSlapSound.play()
		endGremlin()

func endGremlin() -> void:
	continueGremlin = false
	freezers[chosenCooler].canClose = true
	gremlinAnim.play("run")
	
	freezers[chosenCooler].startIceCreamPickup()
	if canRecoverPopsicle:
		freezers[chosenCooler].addRandomIceCream()

func spawnFog() -> void:
	if !fanEnabled:
		if !spawnedFog:
			fogAnim.play("appear")
			spawnedFog = true
		else:
			fogAnim.play("reappear")
			spawnedFog = true
			await get_tree().create_timer(0.5).timeout
		fog.spawnFog()


func _on_fan_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click") and fanBattery > 0:
		fanEnabled = !fanEnabled
		if fanEnabled and spawnedFog:
			fogAnim.play("dissipate")
		if fanEnabled:
			fanAnim.play("spin")
		else:
			fanAnim.play("RESET")

func closeShop():
	activeCustomer = false
	closing.visible = true
	Singleton.inventory = inventory
	closingShop = true
	customerPocket.disabled = true
	for i in freezers:
		i.stopIceCreamPickup()
	for i in 10:
		remainingCustomers += 1
		customerScreenDisplay.text = ("%02d" % remainingCustomers)
		await get_tree().create_timer(0.01).timeout
	for i in 10:
		await get_tree().create_timer(1).timeout
		remainingCustomers -= 1
		customerScreenDisplay.text = ("%02d" % remainingCustomers)
	Singleton.money = currentMoney
	Singleton.soul_coins = soulCoins
	$ChangeScene.play("changeScene")


func _on_change_scene_animation_finished(anim_name):
	if "start" == anim_name:
		newCustomer()
	if "changeScene" == anim_name:
		await get_tree().create_timer(0.6).timeout
		if currentMoney >= Singleton.quota[Singleton.day] and Singleton.day < 4:
			get_tree().change_scene_to_file("res://Scenes/shop.tscn")
		elif currentMoney < Singleton.quota[Singleton.day]:
			Singleton.win = false
			get_tree().change_scene_to_file("res://Scenes/End Screen.tscn")
		else:
			Singleton.win = true
			get_tree().change_scene_to_file("res://Scenes/End Screen.tscn")
 

func _on_customer_pocket_area_entered(area):
	if area.is_in_group("flyswatter") and activeCustomer:
		gremlinSlapSound.play()
		rejectOffer()
		
		customerLeave()
		activeCustomer = false

func updateCoolant(amount):
	coolantGague.value = amount

func loadDay():
	match Singleton.day:
		0:
			DisplayServer.window_set_title("DAY 1")
		1:
			DisplayServer.window_set_title("DAY 2")
		2:
			DisplayServer.window_set_title("DAY 3")
		3:
			DisplayServer.window_set_title("DAY 4")
		4:
			DisplayServer.window_set_title("DAY 5")

	await get_tree().create_timer(5).timeout
	if Singleton.day > 0:
		tentacleSpawnLoop()
	if Singleton.day > 1:
		gremlinSpawnLoop()
	if Singleton.day > 2:
		fogSpawnLoop()
	
func tentacleSpawnLoop():
	var time = randf_range(15,20)
	print(time)
	await get_tree().create_timer(time).timeout
	if !closingShop:
		var cont
		var randFreezer = freezers.pick_random()
		if !randFreezer.tentaclesActive and randFreezer.canClose:
			randFreezer.spawnTentacle()
		tentacleSpawnLoop()

func gremlinSpawnLoop():
	var time = randf_range(10,15)
	print(time)
	await get_tree().create_timer(time).timeout
	if !closingShop:
		spawnGremlin()
		gremlinSpawnLoop()

func fogSpawnLoop():
	var time = randf_range(20,40)
	print(time)
	await get_tree().create_timer(time).timeout
	if !closingShop:
		spawnFog()
		fogSpawnLoop()
