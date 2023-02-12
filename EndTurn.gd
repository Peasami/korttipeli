extends Button
var turnCounter = 0
signal turnEnded(nextTurnNumber)

func _ready():
	pass

func _pressed():
	EndTurn()
	print("ButtonEndTurnIsPressed")


func EndTurn():
	turnCounter += 1
	emit_signal("turnEnded", turnCounter)
	pass
