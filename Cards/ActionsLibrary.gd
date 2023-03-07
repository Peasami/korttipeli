extends Node

signal summon_unit(summonedUnitName, summonedUnitSlotNumber)
signal deal_damage(amount, target)
signal deal_area_damage(dmg, xSize, ySize, targetsToAffect, slotPlayedOn)

func DealDamage(amount, target):
	emit_signal("deal_damage", amount, target)

func SummonAUnit(summonedUnitName, slotNumber):
	emit_signal("summon_unit", summonedUnitName, slotNumber)

func AreaDamage(dmg, xSize, ySize, targetsToAffect, slotPlayedOn):
	emit_signal("deal_area_damage", dmg, xSize, ySize, targetsToAffect, slotPlayedOn)
