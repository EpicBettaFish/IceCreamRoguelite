extends Node

var money: int

var soul_coins: int

var inventory = [10, 10, 10]

var day = 0

var equipment = {
	#for coolant first number is modifier, second is seconds of coolant available
	'coolant' : [false, 2, 30],
	'tentaclespray' : [true],
	'flyswatter' : [true],
	'fan' : [true]
}
