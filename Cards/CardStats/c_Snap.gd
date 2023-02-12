extends "res://Cards/CardBase.gd"

func _init():
	SetName("Snap")
	legalTargets = "Enemy"

func SpellEffect():
	DealDamage(6)
	$'../../'.IncrementAttackCounter()
