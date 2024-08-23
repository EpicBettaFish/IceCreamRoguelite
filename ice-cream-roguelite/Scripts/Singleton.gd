extends Node

var money: float

var soul_coins: int

var totalMoney: float
var totalSoul: int
var customersServed: int

var inventory = [10, 10, 10]

var day = 0

var equipment = {
	#for coolant first number is modifier, second is seconds of coolant available
	'coolant' : [false, 2, 15],
	'tentaclespray' : [false],
	'flyswatter' : [false],
	'fan' : [false]
}

var customerCount = [5, 10, 15, 20, 20, 35]
var quota = [20, 30, 40, 65, 70, 85]

var salesmanText = ["On your way home,\n you meet a strange salesman.", "The salesman from yesterday is outside your ice cream truck.", "The salesman is sitting on the sidewalk, munching on a hamburger.", "You go home, and find the salesman waiting for you outside your apartment complex.", "The salesman didn't have any wears this time, instead, he simply informed you that..."]

var win = false

var fullscreen = false

func _input(event):
	if event.is_action_pressed("fullscreen"):
		fullscreen = !fullscreen
		if fullscreen:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
