extends Control

var hovered_icon = null

@onready var hover_sound = $hover
@onready var press_sound = $press

@onready var info_title = $InfoPanel/title
@onready var info_price = $InfoPanel/price
@onready var info_description = $InfoPanel/description

var clicked_icon = null

func _ready():
	for i in $items.get_child_count():
		$items.get_child(i-1).connect("gui_input", item_click.bind($items.get_child(i-1).item, $items.get_child(i-1)))


func item_click(event, item, node):
	if hovered_icon != item:
		hovered_icon = item
		hover_sound.play()
	if event.is_action_pressed("click") and clicked_icon != item:
		press_sound.play()
		info_description.text = node.info_resource.description
		info_title.text = node.info_resource.title
		info_price.text = str("$ ", node.info_resource.price)

func add_cones(button):
	Singleton.money -= 1
	Singleton.inventory[button] += 1
	$Computer.get_child(button).text = str(Singleton.inventory[button])
	if Singleton.money < 1:
		$Computer/ConeButton.disabled = true
		$Computer/CheesemanButton.disabled = true
		$Computer/RocketButton.disabled = true
