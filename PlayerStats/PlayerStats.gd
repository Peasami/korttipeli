extends Node

var playerHP = 100
var maxMana = 12
var playerMana = 12


func _ready():
	ConnectToEndTurn()
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

func PutManaTo(amountOfMana):
	playerMana = amountOfMana
	UpdateManaBar()

func UpdateManaBar():
	$ManaBar/MarginContainer/Label.text = str(playerMana)

func _on_EndTurn_turnEnded(nextTurnNumber):
	PutManaTo(maxMana)

func ConnectToEndTurn():
	var endTurn = $'../EndTurn'
	endTurn.connect("turnEnded", self, "_on_EndTurn_turnEnded")
