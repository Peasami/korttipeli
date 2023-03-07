extends "res://Units/UnitBase.gd"

onready var CardDatabase = preload("res://Cards/CardDatabase.gd")
onready var unitInfo = CardDatabase.DATA[CardDatabase.get(unitName)]

func _ready():
	unitType = str(unitInfo[0]) 
	unitName = str(unitInfo[1])
	unitAttack = int(unitInfo[3])
	maxHealth = int(unitInfo[4])
	unitText = str(unitInfo[5])
	
	$Bar1/TextureRect/Label.text = unitName
	currentHealth = maxHealth
	UpdateStats()
