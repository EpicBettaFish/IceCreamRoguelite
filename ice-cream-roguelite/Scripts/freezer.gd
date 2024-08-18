extends Node2D

@export var mainPath: NodePath
@onready var main = get_node(mainPath)

@onready var closedLid = $Closed
@onready var openLid = $Open

@export var iceCreamFreezerTexture: Texture
@export var iceCreamNormalTexture: Texture

@export var iceCreamID: int
@onready var iceCreamSpawns = [$IceCreamSpawns/SpawnPos, $IceCreamSpawns/SpawnPos2, $IceCreamSpawns/SpawnPos3, $IceCreamSpawns/SpawnPos4, $IceCreamSpawns/SpawnPos5]

@onready var freezerAreaCollider = $Freezer/CollisionShape2D

var iceCreamScene = preload("res://Scenes/iceCream.tscn")

func _ready():
	closedLid.visible = true
	openLid.visible = false
	spawnIceCreams()

func spawnIceCreams() -> void:
	for i in main.inventory[iceCreamID]:
		var newIceCream = iceCreamScene.instantiate()
		newIceCream.normalTexture = iceCreamNormalTexture
		newIceCream.freezerTexture = iceCreamFreezerTexture
		newIceCream.global_position = iceCreamSpawns[i].global_position
		add_child(newIceCream)

#OPEN FREEZER
func _on_closed_pressed():
	closedLid.visible = false
	openLid.visible = true
	freezerAreaCollider.disabled = false

#CLOSE FREEZER
func _on_open_pressed():
	closedLid.visible = true
	openLid.visible = false
	freezerAreaCollider.disabled = true
