extends "res://Cards/CardBase.gd"

signal summon_unit(summonedUnitName, summonedUnitSlotNumber)

func OnPlayEffect(slotNumber):
	emit_signal("summon_unit", cardName, slotNumber)
	if is_connected("summon_unit", $'../../', "_on_Card_summon"):
		disconnect("summon_unit", $'../../', "_on_Card_summon")
