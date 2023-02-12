extends "res://Cards/CardBase.gd"

func _init():
	SetName("Snap")

func SpellEffect(enemy):
	DealDamage(6, enemy)
	$'../../'.IncrementAttackCounter()
