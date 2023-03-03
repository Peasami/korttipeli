extends "res://Cards/CardBase.gd"

func _init():
	SetName("Meteorite")
	legalTargets = "EnemyArea"

func SpellEffect():
	Actions.AreaDamage(2, 3, 3, "Enemy", targetOfCard)
	$'../../'.IncrementAttackCounter()
