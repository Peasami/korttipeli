extends "res://Cards/CardBase.gd"

func _init():
	SetName("Snap")

func SpellEffect(enemy):
	enemy.TakeDamage(int(cardAttack))
	$'../../'.IncrementAttackCounter()
