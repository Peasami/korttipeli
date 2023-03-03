extends "res://Cards/CardBase.gd"

func _init():
	SetName("Snap")
	legalTargets = "Enemy"

func SpellEffect():
	Actions.DealDamage(6, targetOfCard)
	$'../../'.IncrementAttackCounter()
