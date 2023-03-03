extends "res://Cards/CardBase.gd"

func _init():
	SetName("Snek")
	legalTargets = "OwnEmpty"

func SpellEffect():
	Actions.SummonAUnit(cardName, targetOfCard)
