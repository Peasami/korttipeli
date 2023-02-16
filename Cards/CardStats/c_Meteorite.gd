extends "res://Cards/CardBase.gd"

func _init():
	SetName("Meteorite")
	legalTargets = "EnemyArea"

func SpellEffect():
	AreaDamage(2, 3, 3, "Enemy")
	$'../../'.IncrementAttackCounter()
