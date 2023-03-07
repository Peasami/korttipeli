extends Node

func _ready():
	pass
#	ConnectSignals()

func ConnectSignals(newCard):
	print("Connecting Signals")
	newCard.connect("deal_damage", self, "DealDamage")
	newCard.connect("summon_unit", self, "SummonAUnit")
	newCard.connect("deal_area_damage", self, "AreaDamage")

func SummonAUnit(unitName, unitSlot):
	get_parent()._on_Card_summon(unitName, unitSlot)

func FindTargetFromSlotNumber(slotNumber, targetsToAffect):
	if targetsToAffect == "Enemy":
		var EnemiesInPlay = $'../Enemies'
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
	print("DEALING DAMAGE!!!")
	if target != null:
		target.TakeDamage(amount)

	#WIP__________________________
func AreaDamage(dmg, xSize, ySize, targetsToAffect, slotPlayedOn):
	var slotNumbersToAffect = [slotPlayedOn-5, slotPlayedOn-4, slotPlayedOn-3, slotPlayedOn-1, slotPlayedOn, slotPlayedOn+1, slotPlayedOn+3, slotPlayedOn+4, slotPlayedOn+5]
	for i in slotNumbersToAffect:
		if i >= 16 && i <= 31:
			var enemyTarget = FindTargetFromSlotNumber(i, targetsToAffect)
			DealDamage(dmg, enemyTarget)

func FindAreaSlots(xSize, ySize, targetsToAffect, slotPlayedOn):
	var target = []
	var slotNumbersToAffect = [slotPlayedOn-5, slotPlayedOn-4, slotPlayedOn-3, slotPlayedOn-1, slotPlayedOn, slotPlayedOn+1, slotPlayedOn+3, slotPlayedOn+4, slotPlayedOn+5]
	for i in slotNumbersToAffect:
		if i >= 16 && i <= 31:
			target.append(FindTargetFromSlotNumber(i, targetsToAffect))


func DiscardSelectCard():
	
	pass
