extends MarginContainer

enum{
	inHand
	inPlay
	inMouseHand
	inMousePlay
	inGraveyard
	moveDrawnCardToHand
	reOrganiseHandHand
	inDeck
	fromMouseToHand
}

#onready var CardDatabase = preload("res://Cards/CardDatabase.gd")
#onready var unitInfo = CardDatabase.DATA[CardDatabase.get(unitName)]

var graveYardPos = Vector2(0, 0)


var unitType
var unitName
var unitText
var currentSlotNumber = 12
var maxHealth
var currentHealth
var unitAttack
var unitHealth
var isHero = false

var isInMouse = false
var state
var alreadyWentBack
var alreadyWentToSlot
var foundASlot
var previousPos
var animationTime = 0.1

var maxSlotValueForCard = 15
var minSlotValueForCard = 0

var unitSize = Vector2(75, 75)


func _ready():
	rect_size = unitSize
	
	# Gets info from fields and stores in var's
#	unitType = str(unitInfo[0]) 
#	unitName = str(unitInfo[1])
#	unitAttack = int(unitInfo[3])
#	maxHealth = int(unitInfo[4])
#	unitText = str(unitInfo[5])
#
#	$Bar1/TextureRect/Label.text = unitName
#	currentHealth = maxHealth
#	UpdateStats()
	
	
	

func _physics_process(delta):
	match state:
		inMouseHand, inMousePlay:
			rect_position = get_global_mouse_position() - rect_size/2


func _on_Focus_gui_input(event): # Called if mouse is over Focus, and input event occurs
	if $Tween.is_active() == false: # if the card isn't moving
		MoveUnit(event)

func MoveUnit(event):
	if event.is_action_pressed("left_click"):
		print("left click")
		previousPos = rect_position
		isInMouse = true
		state = inMouseHand

	if event.is_action_pressed("right_click"):
		if isInMouse == true:
			alreadyWentBack = true
			PutCardToPreviousSlot()
			isInMouse = false

	# Looks if mouse is on top of a cardslot and functions accordingly
	if event.is_action_released("left_click"):
		print("leftclickrelease")
		print("isinmouse: ", isInMouse, " / alreadywentoslot: ", alreadyWentToSlot)
		if isInMouse == true && alreadyWentToSlot != true: 
			# Handles dropping on cardslots
			var CardSlots = $'../../CardSlots'
			var cardSlotEmpty = $'../../'.cardSlotEmpty
			for i in range(CardSlots.get_child_count()): # Checks for each cardslot on board
				# If the slot is Free
				if cardSlotEmpty[i] == true && i >= minSlotValueForCard && i <= maxSlotValueForCard:
					# Checks mouse is ontop of slot
					var cardSlotPos = CardSlots.get_child(i).rect_position
					var cardSlotSize = CardSlots.get_child(i).rect_size
					var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
					if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
						previousPos = cardSlotPos
						AnimateACard(animationTime, rect_position, cardSlotPos)
						state = inPlay
						cardSlotEmpty[i] = false
						cardSlotEmpty[currentSlotNumber] = true
						currentSlotNumber = i
						foundASlot = true
						isInMouse = false
						break

				# If there is another card in slot
				elif cardSlotEmpty[i] == false && i != currentSlotNumber:
					var cardSlotSize = CardSlots.get_child(i).rect_size
					var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
					if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
						print("slotfull")
						var UnitsInPlay = $'../../Units'
						for Unit in UnitsInPlay.get_children():
							if Unit.currentSlotNumber == i:
								Unit.DamageTaken(unitAttack)
								break
						AnimateACard(animationTime, get_global_mouse_position() - rect_size/2, previousPos)
						state = inPlay
			if foundASlot == false:
				print("previousPos: ", previousPos)
				if state != inGraveyard:
					AnimateACard(animationTime, get_global_mouse_position() - rect_size/2, previousPos)
					state = inPlay
				isInMouse = false
			foundASlot = false
		else:
			alreadyWentBack = false

func Summon(nameOfUnit, slotNumber):
	unitName = nameOfUnit
	currentSlotNumber = slotNumber

func PutCardToPreviousSlot():
	AnimateACard(animationTime, rect_position, previousPos)
	state = inPlay

func AnimateACard(timeOfAnimation, startingPos, endingPos):
	$Tween.interpolate_property($'.', 'rect_position', 
		startingPos, endingPos, timeOfAnimation,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func DIECARD():
	currentHealth = maxHealth
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	cardSlotEmpty[currentSlotNumber] = true
	currentSlotNumber = null
	print("DIECARD graveyard")
	PutCardToGraveyard()

func TakeDamage(amount):
	print(unitName, " takes ", amount, " damage!")
	currentHealth -= amount
	UpdateStats()
	print(unitName, " HP: ", currentHealth, "/", maxHealth)
	if currentHealth <= 0:
		DIECARD()

func DamageTaken(dmgNumber):
	TakeDamage(dmgNumber)

func PutCardToGraveyard():
	print(unitName, (" is put to graveyard"))
	state = inGraveyard
	AnimateACard(animationTime, rect_position, graveYardPos)
	$'../../'.PutUnitInGraveyard(unitName)
	rect_scale = Vector2(0.5, 0.5)

func UpdateStats():
	$Bar1/HBoxContainer/Attack.text = str(unitAttack)
	$Bar1/HBoxContainer/Health.text = str(currentHealth)

func _on_Focus_mouse_entered():
	pass # Replace with function body.


func _on_Focus_mouse_exited():
	pass # Replace with function body.

func SetName(uName):
	unitName = uName

func SetCurrentSlot(number):
	currentSlotNumber = number
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	cardSlotEmpty[currentSlotNumber] = false
	print("CurrentSlotNumber: ", currentSlotNumber)
