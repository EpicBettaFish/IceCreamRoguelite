extends Node2D

var inventory = [1,1,1]
var grabbingItem = false
var currentOffer = [[1,1,1], 0]
var activeCustomer = true

func _ready():
	get_window().size = Vector2i(960, 540)

func giveIceCream(UNUSED):
	currentOffer = [[0,0,0], 0]
	$AnimationPlayer.play("changeScene")
	$Label2.modulate = "#5eff6e"
	$Label.modulate = "#5eff6e"
	$AudioStreamPlayer2.play()


func _on_animation_player_animation_finished(anim_name):
	if "changeScene" == anim_name:
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://Main.tscn")
