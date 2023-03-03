extends Node

signal summon_unit(summonedUnitName, summonedUnitSlotNumber)
signal deal_damage(amount, target)
signal deal_area_damage(dmg, xSize, ySize, targetsToAffect, slotPlayedOn)


func FindTargetFromSlotNumber(slotNumber, targetsToAffect):
	if targetsToAffect == "Enemy":
		var EnemiesInPlay = $'../../Enemies'
		for Enemy in EnemiesInPlay.get_children():
			if Enemy.cardSlotPos == slotNumber:
				return Enemy
		return null
	elif targetsToAffect == "OwnEmpty":
		if $'../../'.cardSlotEmpty[slotNumber] == true && slotNumber >= 0 && slotNumber <= 15:
			return slotNumber
		else:
			return null
	elif targetsToAffect == "EnemyArea":
		if slotNumber >= 16 && slotNumber <= 31:
			return slotNumber
		else:
			return null


func DealDamage(amount, target):
	print("DealDamageSignal is sent")
	emit_signal("deal_damage", amount, target)
#	if target != null:
#		target.TakeDamage(amount)

func SummonAUnit(summonedUnitName, slotNumber):
	emit_signal("summon_unit", summonedUnitName, slotNumber)

	#WIP__________________________
func AreaDamage(dmg, xSize, ySize, targetsToAffect, slotPlayedOn):
	emit_signal("deal_area_damage", dmg, xSize, ySize, targetsToAffect, slotPlayedOn)
#	var slotNumbersToAffect = [slotPlayedOn-5, slotPlayedOn-4, slotPlayedOn-3, slotPlayedOn-1, slotPlayedOn, slotPlayedOn+1, slotPlayedOn+3, slotPlayedOn+4, slotPlayedOn+5]
#	for i in slotNumbersToAffect:
#		if i >= 16 && i <= 31:
#			var enemyTarget = FindTargetFromSlotNumber(i, targetsToAffect)
#			DealDamage(dmg, enemyTarget)

func FindAreaSlots(xSize, ySize, targetsToAffect, slotPlayedOn):
	var target = []
	var slotNumbersToAffect = [slotPlayedOn-5, slotPlayedOn-4, slotPlayedOn-3, slotPlayedOn-1, slotPlayedOn, slotPlayedOn+1, slotPlayedOn+3, slotPlayedOn+4, slotPlayedOn+5]
	for i in slotNumbersToAffect:
		if i >= 16 && i <= 31:
			target.append(FindTargetFromSlotNumber(i, targetsToAffect))
