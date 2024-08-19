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

var tentacleHits

var activeSlots = [false,false,false,false,false]

var iceCreamScene = preload("res://Scenes/iceCream.tscn")

func _ready():
	tentacleHits = main.tentacleHits
	openLid.visible = false
	tentacleSprite.visible = false
	tentacleArea.disabled = true
	spawnIceCreams()

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

#CLOSE FREEZER
func _on_close_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("click"):
		openLid.visible = false
		freezerAreaCollider.disabled = true

func removeIceCream(index) -> void:
	activeSlots[index] = false
	main.inventory[iceCreamID] -= 1
	if main.inventory[iceCreamID] >= 5: spawnNewIceCream(index)

func addIceCream(index) -> void:
	main.inventory[iceCreamID] += 1
	if activeSlots[index] == false:
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
