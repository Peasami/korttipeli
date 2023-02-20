extends MarginContainer     # Inherits properties from public class "MarginContainer"

signal summon_unit(summonedUnitName, summonedUnitSlotNumber)

const pos1 = Vector2(112,720)
const pos2 = Vector2(212,710)
const pos3 = Vector2(312,700)
const pos4 = Vector2(412,690)
const pos5 = Vector2(512,680)
const pos6 = Vector2(612,690)
const pos7 = Vector2(712,700)
const pos8 = Vector2(812,710)
const pos9 = Vector2(912,720)
const handCardPosition = [pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9]

onready var CardDatabase = preload("res://Cards/CardDatabase.gd")  # when available, gets CardDatabase. Allows this code to access it
var cardName
# from CardDatabase.DATA, gets the value of "cardName" and stores all fields in var 
# (for example, ".get("SmallMan") : Unit","SmallMan", 1, 2, 1, " "
onready var cardInfo = CardDatabase.DATA[CardDatabase.get(cardName)] 


var startPos = 0
var targetPos = 0
var t = 0
var drawTime = 1
var positionInHand = 0
var zoomedIn = false
var oldState = inDeck
var mouseToHandTime = 0.3
var alreadyWentToHand = false
var alreadyWentToSlot = false
var cardSize = Vector2(200, 300)
var slotSize = Vector2(150, 150)
const cardSizeOnSlot = Vector2(150, 150)
var cardInSlotNumber
var graveYardPos = Vector2(0, 0)
var previousPos

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

var state = inDeck # default state

var maxSlotValueForCard = 15
var minSlotValueForCard = 0

var maxHealth
var currentHealth

var cardCost
var cardAttack
var cardHealth
var cardText
var cardType
var playerStats

var legalTargets = "Enemy"
var slotToPlayCardOn
var targetOfCard
var areaSize

func SetName(cName):
	cardName = cName

# Called when card is created
func _ready():
	print(cardInfo) # prints all fields of card
	
	# Gets info from fields and stores in var's
	cardType = str(cardInfo[0]) 
	cardName = str(cardInfo[1])
	if cardType == "Unit":
		cardCost = str(cardInfo[2])
		cardAttack = str(cardInfo[3])
		cardHealth = str(cardInfo[4])
		cardText = str(cardInfo[5])
		$Bars/Bar2/Type/Type.text = cardType
		$Bars/Bar1/Name/Label.text = cardName
		$Bars/Bar1/Cost/Label.text = cardCost
		$Bars/Bar4/Attack/Label.text = cardAttack
		$Bars/Bar4/Health/Label.text = cardHealth
		$Bars/Bar3/SpecialText/Label.text = cardText
		maxHealth = int(cardHealth)
		currentHealth = maxHealth
	elif cardType == "Spell":
		cardCost = str(cardInfo[2])
		cardText = str(cardInfo[3])
		cardAttack = str(cardInfo[4])
		$Bars/Bar2/Type/Type.text = cardType
		$Bars/Bar1/Name/Label.text = cardName
		$Bars/Bar1/Cost/Label.text = cardCost
		$Bars/Bar3/SpecialText/Label.text = cardText
		
	
	playerStats = get_node('../../PlayerStats')
	


var CARD_SELECT = true

var testiming = 0
var foundASlot = false
var isInMouse = false

#func _process(delta):
#	if Input.is_action_just_released("ui_up"):
#		print("inside cardBase: ",self)

func _on_Focus_gui_input(event): # Called if mouse is over Focus, and input event occurs
	PrintStateOnHover()	# DEBUGGING
	
	if $Tween.is_active() == false: # if the card isn't moving
		MoveCard(event)
	else:
		alreadyWentToHand = false

func PrintStateOnHover():
	testiming += 1
	if testiming == 50:
		print(positionInHand)
		testiming = 0

func MoveCard(event):
	match state:
		inHand, inMouseHand:
			if event.is_action_pressed("left_click"):
				DragCardInPlayspace(inMouseHand)
			if event.is_action_pressed("right_click"):
				if isInMouse == true:
					alreadyWentToHand = true
					PutCardToHand()
			if event.is_action_released("left_click"):
				if playerStats.IsEnoughMana(int(cardCost)) == false:
					print("Not enough mana!")
					PutCardToHand()
				elif isInMouse == true && alreadyWentToHand == false:
					var CardSlots = $'../../CardSlots'
					var cardSlotEmpty = $'../../'.cardSlotEmpty
					
					for i in range(CardSlots.get_child_count()):
						var cardSlotPos = CardSlots.get_child(i).rect_position - (cardSize - slotSize)/2
						var cardSlotSize = CardSlots.get_child(i).rect_size
						var localMousePos = CardSlots.get_child(i).get_local_mouse_position()
						if localMousePos.x < cardSlotSize.x && localMousePos.x > 0 && localMousePos.y < cardSlotSize.y && localMousePos.y > 0:
							slotToPlayCardOn = i
							var foundTarget = FindTargetFromSlotNumber(slotToPlayCardOn, legalTargets)
							if foundTarget != null:
								targetOfCard = foundTarget
								playerStats.ReduceMana(int(cardCost))
								SpellEffect()
								$'../../'.ReorganizeHand(positionInHand)
								$'../../'.ReduceHandSize(1)
								PutCardToGraveyard()
								foundASlot = true
					if foundASlot == false:
						PutCardToHand()



# Updates every frame (if mouse is moving over TextureButton)
func _physics_process(delta):
	match state:
		inMouseHand, inMousePlay:
			rect_position = get_global_mouse_position() - rect_size/2

var oldCardPositionY

# Handles when mouse is over card in hand
func _on_Focus_mouse_entered():
	if $Tween.is_active() == false:
		if state in [inHand]:
			zoomedIn = true
			rect_scale = Vector2(1.2, 1.2)
			oldCardPositionY = rect_position.y
			rect_position.y = get_viewport().size.y - 320



# Heandles when mouse leaves card in hand
func _on_Focus_mouse_exited():
	if zoomedIn == true:
		if state == inHand:
			rect_scale = Vector2(1, 1)
			rect_position.y = oldCardPositionY
			
			zoomedIn = false

func AnimateACard(timeOfAnimation, startingPos, endingPos):
	$Tween.interpolate_property($'.', 'rect_position', 
		startingPos, endingPos, timeOfAnimation,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func PutCardToGraveyard():
#	print(cardName, (" is put to graveyard"))
	AnimateACard(mouseToHandTime, rect_position, graveYardPos)
	$'../../'.PutCardInGraveyard(self)
	rect_scale = Vector2(0.5, 0.5)

func DIECARD():
	currentHealth = maxHealth
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	cardSlotEmpty[cardInSlotNumber] = true
	cardInSlotNumber = null
	print("DIECARD graveyard")
	PutCardToGraveyard()

func DragCardInPlayspace(stateToBeIn):
	isInMouse = true
	rect_scale = Vector2(0.8, 0.8)
	state = stateToBeIn

func PutCardToHand():
	isInMouse = false
	rect_scale = Vector2(1, 1)
	AnimateACard(mouseToHandTime, rect_position, handCardPosition[positionInHand] - rect_size/2)
	state = inHand

func PutCardToPreviousSlot():
	rect_scale = Vector2(0.5, 0.5)
	AnimateACard(mouseToHandTime, rect_position, previousPos)
	state = inPlay

func FindTargetFromSlotNumber(slotNumber, targetsToAffect):
	if targetsToAffect == "Enemy":
		var EnemiesInPlay = $'../../Enemies'
		for Enemy in EnemiesInPlay.get_children():
			if Enemy.cardSlotPos == slotNumber:
				return Enemy
				break
		if foundASlot == false:
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

func SpellEffect():
	pass

func DealDamage(amount, target = targetOfCard):
	if target != null:
		target.TakeDamage(int(cardAttack))

func SummonAUnit(summonedUnitName, slotNumber):
	emit_signal("summon_unit", summonedUnitName, slotNumber)
#	if is_connected("summon_unit", $'../../', "_on_Card_summon"):
#		disconnect("summon_unit", $'../../', "_on_Card_summon")

	#WIP__________________________
func AreaDamage(dmg, xSize, ySize, targetsToAffect):
	var stp = slotToPlayCardOn
	var slotNumbersToAffect = [stp-5, stp-4, stp-3, stp-1, stp, stp+1, stp+3, stp+4, stp+5]
	for i in slotNumbersToAffect:
		if i >= 16 && i <= 31:
			var enemyTarget = FindTargetFromSlotNumber(i, targetsToAffect)
			DealDamage(dmg, enemyTarget)
