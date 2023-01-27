extends MarginContainer     # Inherits properties from public class "MarginContainer"
#
#signal useMana(amount)
#
#const pos1 = Vector2(112,720)
#const pos2 = Vector2(212,710)
#const pos3 = Vector2(312,700)
#const pos4 = Vector2(412,690)
#const pos5 = Vector2(512,680)
#const pos6 = Vector2(612,690)
#const pos7 = Vector2(712,700)
#const pos8 = Vector2(812,710)
#const pos9 = Vector2(912,720)
#const handCardPosition = [pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9]
#
#onready var CardDatabase = preload("res://Units/CardDatabase.gd")  # when available, gets CardDatabase. Allows this code to access it
#var cardName = 'BigMan' 
## from CardDatabase.DATA, gets the value of "cardName" and stores all fields in var 
## (for example, ".get("SmallMan") : Unit","SmallMan", 1, 2, 1, " "
#onready var cardInfo = CardDatabase.DATA[CardDatabase.get(cardName)] 
#
#
#var startPos = 0
#var targetPos = 0
#var t = 0
#var drawTime = 1
#var positionInHand = 0
#onready var tween = $Tween
#var zoomedIn = false
#var oldState = inDeck
#var mouseToHandTime = 0.3
#var alreadyWentToHand = false
#var alreadyWentToSlot = false
#var cardSize = Vector2(200, 300)
#var slotSize = Vector2(150, 150)
#const cardSizeOnSlot = Vector2(150, 150)
#var cardInSlotNumber
#var graveYardPos = Vector2(0, 0)
#var previousPos
#
#enum{
#	inHand
#	inPlay
#	inMouseHand
#	inMousePlay
#	inGraveyard
#	moveDrawnCardToHand
#	reOrganiseHandHand
#	inDeck
#	fromMouseToHand
#}
#
#var state = inDeck # default state
#
#var maxSlotValueForCard = 15
#var minSlotValueForCard = 0
#
#var maxHealth
#var currentHealth
#
#var cardCost
#var cardAttack
#var cardHealth
#var cardText
#var cardType
#var playerStats
#
## Called when card is created
#func _ready():
#	print(cardInfo) # prints all fields of card
#
#	# Gets info from fields and stores in var's
#	cardType = str(cardInfo[0]) 
#	cardName = str(cardInfo[1])
#	if cardType == "Unit":
#		cardCost = str(cardInfo[2])
#		cardAttack = str(cardInfo[3])
#		cardHealth = str(cardInfo[4])
#		cardText = str(cardInfo[5])
#		$Bars/Bar2/Type/Type.text = cardType
#		$Bars/Bar1/Name/Label.text = cardName
#		$Bars/Bar1/Cost/Label.text = cardCost
#		$Bars/Bar4/Attack/Label.text = cardAttack
#		$Bars/Bar4/Health/Label.text = cardHealth
#		$Bars/Bar3/SpecialText/Label.text = cardText
#		maxHealth = int(cardHealth)
#		currentHealth = maxHealth
#	elif cardType == "Spell":
#		cardCost = str(cardInfo[2])
#		cardText = str(cardInfo[3])
#		cardAttack = str(cardInfo[4])
#		$Bars/Bar2/Type/Type.text = cardType
#		$Bars/Bar1/Name/Label.text = cardName
#		$Bars/Bar1/Cost/Label.text = cardCost
#		$Bars/Bar3/SpecialText/Label.text = cardText
#
#
#	playerStats = get_node('../../PlayerStats')
#
#
#
#var CARD_SELECT = true
#
#var testiming = 0
#var foundASlot = false
#var isInMouse = false
#
#func _on_Focus_gui_input(event): # Called if mouse is over Focus, and input event occurs
#
#	# DEBUGGING
#	testiming += 1
#	if testiming == 50:
#		print(state)
#		testiming = 0
#
#	if $Tween.is_active() == false: # if the card isn't moving
#		if cardType == "Unit":
#			match state:
#				# Handles if dragging from hand
#				inHand, inMouseHand:
#					if event.is_action_pressed("left_click"):
#						DragCardInPlayspace()
#						state = inMouseHand
#
#					# Right click always moves card to hand
#					if event.is_action_pressed("right_click"):
#						if isInMouse == true:
#							isInMouse = false
#							alreadyWentToHand = true
#							PutCardToHand()
#
#					# Looks if mouse is on top of a cardslot and functions accordingly
#					if event.is_action_released("left_click"):
#						if playerStats.IsEnoughMana(int(cardCost)) == false:
#							print("Not enough mana!")
#							PutCardToHand()
#							isInMouse = false
#						elif isInMouse == true && alreadyWentToHand == false:
#							# Handles dropping on cardslots
#							var CardSlots = $'../../CardSlots'
#							var cardSlotEmpty = $'../../'.cardSlotEmpty
#							for i in range(CardSlots.get_child_count()): # Checks for each cardslot on board
#								if cardSlotEmpty[i] && i >= minSlotValueForCard && i <= maxSlotValueForCard:
#									# Checks mouse is ontop of slot
#									var cardSlotPos = CardSlots.get_child(i).rect_position - (cardSize - slotSize)/2
#									previousPos = cardSlotPos
#									var cardSlotSize = CardSlots.get_child(i).rect_size
#									var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
#									if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
#										rect_scale = Vector2(1, 1)
#										AnimateACard(mouseToHandTime, rect_position, cardSlotPos)
#										state = inPlay
#										$'../../'.ReorganizeHand(positionInHand)
#										cardInSlotNumber = i
#										rect_scale = Vector2(0.5, 0.5)
#										foundASlot = true
#										isInMouse = false
#										cardSlotEmpty[i] = false
#										playerStats.ReduceMana(int(cardCost))
#										print("mana left: ", playerStats.playerMana)
#										break
#							if foundASlot == false:
#								PutCardToHand()
#								isInMouse = false
#							foundASlot = false
#					else:
#						alreadyWentToHand = false
#
#				# Handles if dragging from slot
#				inPlay, inMousePlay:
#					if event.is_action_pressed("left_click"):
#						DragCardInPlayspace()
#						state = inMousePlay
#
#					if event.is_action_pressed("right_click"):
#						if isInMouse == true:
#							alreadyWentToHand = true
#							PutCardToPreviousSlot()
#							isInMouse = false
#
#					# Looks if mouse is on top of a cardslot and functions accordingly
#					if event.is_action_released("left_click"):
#						if isInMouse == true:
#							if alreadyWentToSlot == false:
#
#								# Handles dropping on cardslots
#								var CardSlots = $'../../CardSlots'
#								var cardSlotEmpty = $'../../'.cardSlotEmpty
#								for i in range(CardSlots.get_child_count()): # Checks for each cardslot on board
#
#									# If the slot is Free
#									if cardSlotEmpty[i] && i >= minSlotValueForCard && i <= maxSlotValueForCard:
#										# Checks mouse is ontop of slot
#										var cardSlotPos = CardSlots.get_child(i).rect_position - (cardSize - slotSize)/2
#										var cardSlotSize = CardSlots.get_child(i).rect_size
#										print("cardslot size: ", cardSlotSize)
#										var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
#										if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
#											previousPos = cardSlotPos
#											AnimateACard(mouseToHandTime, rect_position, cardSlotPos)
#											state = inPlay
#											cardSlotEmpty[i] = false
#											cardSlotEmpty[cardInSlotNumber] = true
#											cardInSlotNumber = i
#											rect_scale = Vector2(0.5, 0.5)
#											foundASlot = true
#											isInMouse = false
#											break
#
#									# If there is another card in slot
#									elif cardSlotEmpty[i] == false && i != cardInSlotNumber:
#										var cardSlotSize = CardSlots.get_child(i).rect_size
#										var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
#										if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
#											print("slotfull")
#											var CardsInPlay = $'../../Cards'
#											for Card in CardsInPlay.get_children():
#												if Card.cardInSlotNumber == i:
#													var dmgDealt = DamageDealt()
#													Card.DamageTaken(dmgDealt)
#													var dmgDealtAttacker = Card.DamageDealt()
#													DamageTaken(dmgDealtAttacker)
#													break
#								if foundASlot == false:
#									print("previousPos: ", previousPos)
#									rect_scale = Vector2(0.5, 0.5)
#									if state != inGraveyard:
#										AnimateACard(mouseToHandTime, get_global_mouse_position() - rect_size/2, previousPos)
#										state = inPlay
#									isInMouse = false
#								foundASlot = false
#						else:
#							alreadyWentToHand = false
#				inGraveyard:
#					return
#
#
#		elif cardType == "Spell":
#			match state:
#				inHand, inMouseHand:
#					if event.is_action_pressed("left_click"):
#						DragCardInPlayspace()
#						state = inMouseHand
#					if event.is_action_pressed("right_click"):
#						if isInMouse == true:
#							isInMouse = false
#							alreadyWentToHand = true
#							print("Spell putCardToHand")
#							PutCardToHand()
#					if event.is_action_released("left_click"):
#						if playerStats.IsEnoughMana(int(cardCost)) == false:
#							print("Not enough mana!")
#							PutCardToHand()
#							isInMouse = false
#						if isInMouse == true && alreadyWentToHand == false:
#							var CardSlots = $'../../CardSlots'
#							var cardSlotEmpty = $'../../'.cardSlotEmpty
#							for i in range(CardSlots.get_child_count()):
#								if cardSlotEmpty[i] == false:
#									# Checks mouse is ontop of slot
#									var cardSlotPos = CardSlots.get_child(i).rect_position - (cardSize - slotSize)/2
#									var cardSlotSize = CardSlots.get_child(i).rect_size
#									var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
#
#									SpellEffect(localMousePos, cardSlotPos, cardSlotSize, i)
#									PutCardToGraveyard()
#									foundASlot = true
#							if foundASlot == false:
#								PutCardToHand()
#								isInMouse = false
#							foundASlot = false
#
#	else:
#		alreadyWentToHand = false
#
#
## Updates every frame (if mouse is moving over TextureButton)
#func _physics_process(delta):
#	match state:
#		inMouseHand, inMousePlay:
#			rect_position = get_global_mouse_position() - rect_size/2
#
#var oldCardPositionY
#
## Handles when mouse is over card in hand
#func _on_Focus_mouse_entered():
#	if $Tween.is_active() == false:
#		if state in [inHand]:
#			zoomedIn = true
#			rect_scale = Vector2(1.2, 1.2)
#			oldCardPositionY = rect_position.y
#			rect_position.y = get_viewport().size.y - 320
#
#
#
## Heandles when mouse leaves card in hand
#func _on_Focus_mouse_exited():
#	if zoomedIn == true:
#		if state == inHand:
#			rect_scale = Vector2(1, 1)
#			rect_position.y = oldCardPositionY
#
#			zoomedIn = false
#
#func AnimateACard(timeOfAnimation, startingPos, endingPos):
#	$Tween.interpolate_property($'.', 'rect_position', 
#		startingPos, endingPos, timeOfAnimation,
#		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
#	$Tween.start()
#
#
#func PutCardToGraveyard():
#	print(cardName, (" is put to graveyard"))
#	state = inGraveyard
#	AnimateACard(mouseToHandTime, rect_position, graveYardPos)
#	$'../../'.PutCardInGraveyard(cardName)
#	rect_scale = Vector2(0.5, 0.5)
#
#func DIECARD():
#	currentHealth = maxHealth
#	var cardSlotEmpty = $'../../'.cardSlotEmpty
#	cardSlotEmpty[cardInSlotNumber] = true
#	cardInSlotNumber = null
#	PutCardToGraveyard()
#
#func TakeDamage(amount):
#	print(cardName, " takes ", amount, " damage!")
#	currentHealth -= amount
#	print(cardName, " HP: ", currentHealth, "/", maxHealth)
#	$Bars/Bar4/Health/Label.text = str(currentHealth)
#	if currentHealth <= 0:
#		DIECARD()
#
#func DragCardInPlayspace():
#	isInMouse = true
#	rect_scale = Vector2(0.8, 0.8)
#
#func PutCardToHand():
#	rect_scale = Vector2(1, 1)
#	AnimateACard(mouseToHandTime, rect_position, handCardPosition[positionInHand] - rect_size/2)
#	state = inHand
#
#func PutCardToPreviousSlot():
#	rect_scale = Vector2(0.5, 0.5)
#	AnimateACard(mouseToHandTime, rect_position, previousPos)
#	state = inPlay
#
#
#
#func DamageTaken(dmgNumber):
#	match cardName:
#		"GiantDad":
#			TakeDamage(dmgNumber - 1)
#		_:
#			TakeDamage(dmgNumber)
#
##Attacking functions for each card
#func DamageDealt():
#	match cardName:
#		_:
#			return int(cardAttack)
#
#
#
#func SpellEffect(localMousePos, cardSlotPos, cardSlotSize, i):
#	match cardName:
#		"Snap":
#			if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
#				var CardsInPlay = $'../../Cards'
#				for Card in CardsInPlay.get_children():
#					if Card.cardInSlotNumber == i:
#						Card.DamageTaken(int(cardAttack))
#
