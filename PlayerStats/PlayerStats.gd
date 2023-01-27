extends Node

var playerHP = 100
var playerMana = 12


func _ready():
	UpdateManaBar()

func ReduceMana(amount):
	playerMana -= amount
	print("mana left: ", playerMana)
	UpdateManaBar()

func IsEnoughMana(amount):
	var mana = playerMana
	if mana - amount >= 0:
		return true
	else:
		return false
	

func UpdateManaBar():
	$ManaBar/MarginContainer/Label.text = str(playerMana)
