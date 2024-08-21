extends Control



func _ready():
	for i in $items.get_child_count():
		$items.get_child(i-1).connect("gui_input", item_click.bind($items.get_child(i-1).item))
	
func item_click(event, item):
	if event.is_action_pressed("click"):
		pass
