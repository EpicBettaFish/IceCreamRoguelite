extends Node2D

var inventory = [1,1,1]
var grabbingItem = false
var currentOffer = [[1,1,1], 0]
var activeCustomer = true


func _ready():
	if Singleton.win:
		$result.text = "YOU WON!"
		$dec.text = "Your business is thriving!"
	else:
		$result.text = "YOU FAILED"
		$dec.text = "Your business is on its last legs..."
	
	$customers.text = str("Customers Served: ", Singleton.customersServed)
	$money.text = str("Total Money Earned: $", Singleton.totalMoney)
	$soul.text = str("Total Soul Harvested: ", Singleton.totalSoul)

func giveIceCream(UNUSED):
	currentOffer = [[0,0,0], 0]
	$AnimationPlayer.play("changeScene")
	$AudioStreamPlayer2.play()
	$result.modulate = "#5eff6e"
	$dec.modulate = "#5eff6e"
	$customers.modulate = "#5eff6e"
	$money.modulate = "#5eff6e"
	$soul.modulate = "#5eff6e"
	$insert.modulate = "#5eff6e"


func _on_animation_player_animation_finished(anim_name):
	if "changeScene" == anim_name:
		Singleton.money = 0.0
		Singleton.soul_coins = 0
		Singleton.totalMoney = 0.0
		Singleton.totalSoul = 0
		Singleton.customersServed = 0
		Singleton.inventory = [10, 10, 10]
		Singleton.day = 0
		Singleton.equipment = {
			#for coolant first number is modifier, second is seconds of coolant available
			'coolant' : [false, 2, 15],
			'tentaclespray' : [false],
			'flyswatter' : [false],
			'fan' : [false]
		}
		Singleton.win = false
		
		await get_tree().create_timer(1).timeout
		get_tree().change_scene_to_file("res://Main.tscn")
