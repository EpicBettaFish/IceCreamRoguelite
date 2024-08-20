extends Node2D

@export var mainPath: NodePath
@onready var main = get_node(mainPath)

@onready var openLid = $FreezerOpen

@export var iceCreamID: int
@onready var iceCreamSpawns = [$IceCreamSpawns/SpawnPos, $IceCreamSpawns/SpawnPos2, $IceCreamSpawns/SpawnPos3, $IceCreamSpawns/SpawnPos4, $IceCreamSpawns/SpawnPos5]

@onready var freezerAreaCollider = $FreezerOpen/FreezerArea/CollisionPolygon2D

@onready var openAreaCollider = $Open/CollisionPolygon2D
@onready var tentacleSprite = $Tentacle
@onready var tentacleArea = $TentacleArea/CollisionPolygon2D

var temperature = -16
@onready var temperatureGauge = $Skew/Temperature
@onready var temperatureReadout = $Skew/Readout
@onready var temperatureCelsius = $Skew/Degrees
var freezerOpen = false
var targetTemp = 0
var overheating = false
@export var heatLimit = 29

var coolant = false
var coolantSpeed = 1

var tentacleHits

var activeSlots = [false,false,false,false,false]

var iceCreamScene = preload("res://Scenes/iceCream.tscn")

func _ready():
	tentacleHits = main.tentacleHits
	openLid.visible = false
	tentacleSprite.visible = false
	tentacleArea.disabled = true
	spawnIceCreams()
	
	main.freezers.append(self)
	
	var tempRand = randi_range(-2,2)
	temperature += tempRand
	targetTemp = temperature
	temperatureGauge.value = temperature
	var prefix = ""
	if int(temperature) < 0:
		prefix = "-"
	temperatureReadout.text = prefix + ("%02d" % abs(temperature))

func _process(delta):
	if freezerOpen and !overheating:
		if !coolant:
			temperature += delta * 2
		temperatureGauge.value = temperature
		var prefix = ""
		if int(temperature) < 0:
			prefix = "-"
		temperatureReadout.text = prefix + ("%02d" % abs(temperature))
		if int(temperature) >= 29:
			overheat()
	elif temperature > targetTemp and !freezerOpen:
		var temperatureModifier = delta * 2
		if overheating:
			temperatureModifier = delta
			if temperature <= targetTemp + 4:
				stopOverheat()
		if coolant:
			temperatureModifier *= coolantSpeed
			temperature -= temperatureModifier
		temperatureGauge.value = temperature
		var prefix = ""
		if int(temperature) < 0:
			prefix = "-"
		temperatureReadout.text = prefix + ("%02d" % abs(temperature))

func spawnIceCreams() -> void:
	for i in main.inventory[iceCreamID]:
		if i == 5: return
		spawnNewIceCream(i)

func spawnNewIceCream(index) -> void:
	var newIceCream = iceCreamScene.instantiate()
	newIceCream.global_position = iceCreamSpawns[index].global_position
	newIceCream.spawnIndex = index
	newIceCream.freezer = self
	newIceCream.iceCreamType = iceCreamID
	newIceCream.main = main
	activeSlots[index] = true
	add_child(newIceCream)

#OPEN FREEZER
func _on_open_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		openLid.visible = true
		freezerAreaCollider.disabled = false
		freezerOpen = true

#CLOSE FREEZER
func _on_close_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		openLid.visible = false
		freezerAreaCollider.disabled = true
		freezerOpen = false

func removeIceCream(index) -> void:
	activeSlots[index] = false
	main.inventory[iceCreamID] -= 1
	if main.inventory[iceCreamID] >= 5 and !overheating: spawnNewIceCream(index)

func addIceCream(index) -> void:
	main.inventory[iceCreamID] += 1
	if activeSlots[index] == false and !overheating:
		activeSlots[index] = true
		spawnNewIceCream(index)


#Tentacle
func spawnTentacle() -> void:
	openLid.visible = false
	freezerAreaCollider.disabled = true
	tentacleHits = main.tentacleHits
	openAreaCollider.disabled = true
	tentacleArea.disabled = false
	tentacleSprite.visible = true

func _on_tentacle_area_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		tentacleHits -= 1
		if tentacleHits == 0:
			openAreaCollider.disabled = false
			tentacleArea.disabled = true
			tentacleSprite.visible = false

#Temperature
func overheat() -> void:
	for i in get_children():
		if i.is_in_group("icecream"):
			if !i.pickup:
				i.queue_free()
	overheating = true
	if !coolant:
		temperatureReadout.modulate = "ff0000"
		temperatureCelsius.modulate = "ff0000"

func stopOverheat() -> void:
	overheating = false
	if !coolant:
		temperatureReadout.modulate = "ffcd00"
		temperatureCelsius.modulate = "ffcd00"
	spawnIceCreams()

func coolantStart() -> void:
	coolant = true
	temperatureReadout.modulate = "00cdff"
	temperatureCelsius.modulate = "00cdff"
	coolantSpeed = main.coolantSpeed

func coolantEnd() -> void:
	coolant = false
	if overheating:
		temperatureReadout.modulate = "ff0000"
		temperatureCelsius.modulate = "ff0000"
	else:
		temperatureReadout.modulate = "ffcd00"
		temperatureCelsius.modulate = "ffcd00"
