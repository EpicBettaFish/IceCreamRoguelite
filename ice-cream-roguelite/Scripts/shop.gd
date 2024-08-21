extends Control

var hovered_icon = null

@onready var hover_sound = $hover
@onready var press_sound = $press

func _ready():
	for i in $items.get_child_count():
		$items.get_child(i-1).connect("gui_input", item_click.bind($items.get_child(i-1).item))


func item_click(event, item):
	if hovered_icon != item:
		hovered_icon = item
		hover_sound.play()
	if event.is_action_pressed("click"):
		press_sound.play()

func add_cones(button):
	Singleton.money -= 1
	Singleton.inventory[button] += 1
	$Computer.get_child(button).text = str(Singleton.inventory[button])
	if Singleton.money < 1:
		$Computer/ConeButton.disabled = true
		$Computer/CheesemanButton.disabled = true
		$Computer/RocketButton.disabled = true
