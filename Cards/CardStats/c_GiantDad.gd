extends "res://Cards/CardBase.gd"

func _init():
	SetName("GiantDad")
	legalTargets = "OwnEmpty"

func SpellEffect():
	Actions.SummonAUnit(cardName, targetOfCard)
