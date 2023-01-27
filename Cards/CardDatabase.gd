# UnitInfo = [Type, name, Cost, Attack, Health, special info]

enum{BigMan, SmallMan, Skeletron, Snek, GiantDad, Snap}

const DATA ={
	BigMan:
		["Unit", "BigMan", 3, 3, 4, "Does 1 damage to itself and another unit", "res://Cards/CardStats/c_BigMan.tscn"],
	SmallMan:
		["Unit","SmallMan", 1, 2, 1, " ", "res://Cards/CardStats/c_SmallMan.tscn"],
	Skeletron:
		["Unit","Skeletron", 2, 4, 1, " ", "res://Cards/CardStats/c_Skeletron.tscn"],
	Snek:
		["Unit","Snek", 1, 4, 2, "Dies when does damage", "res://Cards/CardStats/c_Snek.tscn", "res://Units/UnitEffects/u_Snek.tscn"],
	GiantDad:
		["Unit","GiantDad", 4, 4, 5, "Takes 1 less damage", "res://Cards/CardStats/c_GiantDad.tscn", "res://Units/UnitEffects/u_GiantDad.tscn"],
	Snap:
		["Spell","Snap", 1, "Deals 6 damage to one unit", 6, null, "res://Cards/CardStats/c_Snap.tscn"]
}

func Damage(attackerName):
	match attackerName:
		GiantDad:
			return
		_:
			return
