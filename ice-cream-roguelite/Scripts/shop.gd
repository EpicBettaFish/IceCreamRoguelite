extends Control

var hovered_icon = null

@onready var hover_sound = $hover
@onready var press_sound = $press

@onready var info_title = $InfoPanel/title
@onready var info_price = $InfoPanel/price
@onready var info_description = $InfoPanel/description

@onready var moneyDisplay = $Money
@onready var coinDisplay = $"Soul Coin Counter/number"

var clicked_icon = null

var selectedItem
var selectedPrice = 0

func _ready():
	$ColorRect/Label.text = Singleton.salesmanText[Singleton.day]
	moneyDisplay.text = "$"+("%0.2f" % Singleton.money)
	coinDisplay.text = str(Singleton.soul_coins)
	for i in $items.get_child_count():
		$items.get_child(i-1).connect("gui_input", item_click.bind($items.get_child(i-1).item, $items.get_child(i-1)))
	if Singleton.money < 1:
		$Computer/ConeButton.disabled = true
		$Computer/CheesemanButton.disabled = true
		$Computer/RocketButton.disabled = true
	$Computer/cones.text = str(Singleton.inventory[0])
	$Computer/cheeseman.text = str(Singleton.inventory[1])
	$Computer/rocket.text = str(Singleton.inventory[2])
	if Singleton.soul_coins > 0:
		$Conversion/Convert.disabled = false
	else:
		$Conversion/Convert.disabled = true
	match Singleton.day:
		0:
			DisplayServer.window_set_title("I SCREAM")
		1:
			DisplayServer.window_set_title("YOU SCREAM")
		2:
			DisplayServer.window_set_title("WE ALL SCREAM")
		3:
			DisplayServer.window_set_title("FOR I SCREAM")


func item_click(event, item, node):
	if hovered_icon != item:
		hovered_icon = item
		hover_sound.play()
	if event.is_action_pressed("click") and clicked_icon != item:
		$InfoPanel.visible = true
		press_sound.play()
		info_description.text = node.info_resource.description
		info_title.text = node.info_resource.title
		info_price.text = str(node.info_resource.price)
		selectedItem = node.singletonName
		selectedPrice = node.info_resource.price
		if Singleton.soul_coins >= node.info_resource.price and Singleton.equipment[node.singletonName][0] == false:
			$InfoPanel/Purchase.disabled = false
		else:
			$InfoPanel/Purchase.disabled = true

func add_cones(button):
	Singleton.money -= 1
	moneyDisplay.text = "$"+("%0.2f" % Singleton.money)
	Singleton.inventory[button] += 1
	$Computer.get_child(button).text = str(Singleton.inventory[button])
	if Singleton.money < 1:
		$Computer/ConeButton.disabled = true
		$Computer/CheesemanButton.disabled = true
		$Computer/RocketButton.disabled = true


func _on_purchase_pressed():
	Singleton.equipment[selectedItem][0] = true
	if selectedItem == "coolant":
		Singleton.equipment[selectedItem][1] = 4
		Singleton.equipment[selectedItem][2] = 30
	$InfoPanel/Purchase.disabled = true
	Singleton.soul_coins -= selectedPrice
	coinDisplay.text = str(Singleton.soul_coins)
	if Singleton.soul_coins > 0:
		$Conversion/Convert.disabled = false
	else:
		$Conversion/Convert.disabled = true


func _on_animation_player_animation_finished(anim_name):
	if "changeScene" == anim_name:
		Singleton.day += 1
		if Singleton.day <= 5:
			get_tree().change_scene_to_file("res://Main.tscn")


func _on_continue_pressed():
	$Continue.disabled = true
	$AnimationPlayer.play("changeScene")


func _on_over_button_pressed():
	$Computer.visible = false
	$Conversion.visible = true


func _on_convert_pressed():
	Singleton.soul_coins -= 1
	Singleton.money += 5.0
	moneyDisplay.text = "$"+("%0.2f" % Singleton.money)
	coinDisplay.text = str(Singleton.soul_coins)
	if Singleton.soul_coins > 0:
		$Conversion/Convert.disabled = false
	else:
		$Conversion/Convert.disabled = true


func _on_back_button_pressed():
	$Computer.visible = true
	$Conversion.visible = false
