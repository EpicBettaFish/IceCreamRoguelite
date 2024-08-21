extends Node2D

# exports for editor
@export var fog: Sprite2D
@export var fogWidth = 1000
@export var fogHeight = 1000
@export var LightTexture: CompressedTexture2D
@export var lightWidth = 300
@export var lightHeight = 300
@export var Player: CharacterBody2D
@export var debounce_time = 0.01

@export var fogNoise: Texture

@export var active: bool = false

# debounce counter helper
var time_since_last_fog_update = 0.0

var fogImage: Image
var lightImage: Image
var light_offset: Vector2
var fogTexture: ImageTexture
var light_rect: Rect2
var noiseImage: Image
var noiseTexture: ImageTexture

var targetPos = Vector2(0,0)
var targetNextPos = Vector2(0,0)

@onready var mouse = $Mouse
var previousMousePos = Vector2(0,0)

func spawnFog():
	var previousMousePos = get_global_mouse_position()
	mouse.global_position = get_global_mouse_position()
	lightImage = LightTexture.get_image()
	lightImage.resize(lightWidth, lightHeight)


	light_offset = Vector2(lightWidth/2, lightHeight/2)


	fogImage = Image.create(fogWidth, fogHeight, false, Image.FORMAT_RGBA8)
	fogImage.fill(Color.BLACK)
	fogTexture = ImageTexture.create_from_image(fogImage)
	fog.texture = fogTexture
	
	noiseImage = fogNoise.get_image()
	noiseImage.convert(Image.FORMAT_RGBA8)
	noiseTexture = ImageTexture.create_from_image(noiseImage)
	$Fog.texture = noiseTexture

	light_rect = Rect2(Vector2.ZERO, lightImage.get_size())
	
	newPos()
	


func _process(delta):
	targetNextPos = targetNextPos.move_toward(targetPos, delta * 3)
	global_position = global_position.lerp(targetNextPos, delta)
	if targetNextPos.distance_to(targetPos) < 0.1:
		newPos()
	mouse.global_position = mouse.global_position.lerp(get_global_mouse_position(), delta * 20)
	if previousMousePos != mouse.global_position and active:
		update_fog(mouse.global_position)
		previousMousePos = mouse.global_position

func update_fog(pos):
	fogImage.blend_rect(lightImage, light_rect, pos - light_offset)
	fogTexture.update(fogImage)
	noiseImage.blend_rect(lightImage, light_rect, pos - light_offset)
	noiseTexture.update(noiseImage)


func newPos() -> void:
	var x = randf_range(-14, 0)
	var y = randf_range(-8, 0)
	targetPos = Vector2(x,y)
