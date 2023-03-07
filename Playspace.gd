extends Node2D

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

var attackCounter = 0
var maxHandSize = 5
var graveYardPos = Vector2(0, 0)

# Max hand size is 5
# Positions for cards in hand
#			5
#		  4   6
#		3	5	7
# 	  2   4   6   8
#	1	3	5	7	9

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

const slotSize = Vector2(100, 100)
const slotScale = Vector2(0.75, 0.5)
const cardScale = Vector2(1, 1) # Used to scale the card (default (1,1))
const cardSize = Vector2(200, 300)
const cardSizeOnSlot = Vector2(150, 150)

const enemy = preload("res://Enemies/EnemyBase.tscn")
const cardBase = preload("res://Cards/CardBase.tscn")
const playerDeck = preload("res://Cards/PlayerDeck.gd")
const cardSlot = preload("res://Cards/CardSlot.tscn")
var cardDatabase = preload("res://Cards/CardDatabase.gd")


onready var playerDeckPosition = $PlayerDeck.position
onready var centerOfHand = Vector2(512, 500)
var cardsInHand = []
var cardsInDeck = []
var cardsInGraveyard = []

const animTime = 0.3

var cardSelected = []
var deckSize
var handSize = 0

var cardSlotEmpty = []

var cardSlotScale = Vector2(0.6, 0.6)
var numberOfColumns = 4
var numberOfRows = 4
var cardSlotsPerSide = numberOfColumns * numberOfRows
onready var viewportSize = get_viewport().size
onready var outerMarginX = viewportSize.x / 7
onready var outerMarginY = viewportSize.y / 10
onready var middleMarginX = 140
onready var cardZoneHeight = cardSize.y / 2
onready var cardSlotGapsY = 0
onready var cardSlotGapsX = 0
onready var cardSlotBaseWidth = viewportSize.x / 10
onready var cardSlotTotalHeight = viewportSize.y - outerMarginY - cardZoneHeight
onready var cardSlotTotalWidth = slotSize.x * 3 + cardSlotGapsX * 2
onready var heightForCard = (cardSlotTotalHeight - (numberOfRows - 1) * cardSlotGapsY) / numberOfRows
onready var widthForCard = (cardSlotTotalWidth - (numberOfColumns - 1) * cardSlotGapsX) / numberOfColumns

func _ready():
	# makes new random seed
	randomize()
	ConnectToEndTurn()
	
	MakeGrid()
	
	for i in playerDeck.cardList:
		var newCard = InstanceNewCard(i)
		newCard.state = inDeck
		cardsInDeck.append(newCard)
		var newCardActions = newCard.get_node("ActionLibrary")
		$ActionLibraryBase.ConnectSignals(newCardActions)
	
	SummonAUnit(6, "Hero1")
	SummonAnEnemy(22)
	SummonAnEnemy(23)
	SummonAnEnemy(29)

func _process(delta):
	if Input.is_action_just_released("ui_up"):
		print(cardsInDeck)
		print(cardsInDeck.size())
		pass
	elif Input.is_action_just_released("ui_down"):
		print(cardsInGraveyard)
		print(cardsInGraveyard.size())
		pass
	elif Input.is_action_just_released("ui_right"):
		print(cardsInHand)
		print(cardsInHand.size())
		pass
	elif Input.is_key_pressed(KEY_K):
		print("CARDSTATES: ")
		for Card in $Cards.get_children():
			print(Card.state)

func InstanceNewCard(nameOfNewCard):
	var cardInfo = cardDatabase.DATA[cardDatabase.get(nameOfNewCard)]
	var cardPath = cardInfo[6]
	var newCard = load(cardPath).instance()
	$Cards.add_child(newCard, true)
	return newCard


func DrawCard(amount = 1):
	for i in range(amount):
		if cardsInHand.size() == maxHandSize:
			return
		if cardsInDeck.size() == 0:
			var isGYFull = ReShuffleDeck()
			if isGYFull == 1: #if there's no graveyard
				return
		
		cardSelected = randi() % cardsInDeck.size()
		var newCard = cardsInDeck[cardSelected]
		
		MoveCardBetweenZones(newCard, cardsInDeck, cardsInHand)
		newCard.positionInHand = 4 + (cardsInHand.size())
		ReorganizeHand(-newCard.positionInHand)
		
		newCard.AnimateACard(animTime, playerDeckPosition - newCard.rect_size/2, handCardPosition[newCard.positionInHand] - newCard.rect_size/2) # Animate card to hand
		newCard.state = inHand


func ConnectToEndTurn():
	var endTurn = $'EndTurn'
	endTurn.connect("turnEnded", self, "_on_EndTurn_turnEnded")

func DiscardCard(positionForDiscarded):
	for Card in $Cards.get_children():
		if Card.positionInHand == positionForDiscarded && Card.state == inHand:
			ReorganizeHand(positionForDiscarded)
			ReduceHandSize(1)
			Card.PutCardToGraveyard()

#Makes grid of slots
# [0] [4]  [8] [12]   [16] [20] [24] [28]
# [1] [5]  [9] [13]   [17] [21] [25] [29]
# [2] [6] [10] [14]   [18] [22] [26] [30]
# [3] [7] [11] [15]   [19] [23] [27] [31]
func MakeGrid():
	for i in range(2):
		for j in range(numberOfColumns):
			for k in range(numberOfRows):
				var newSlot = cardSlot.instance()
				newSlot.rect_scale = cardSlotScale
				newSlot.rect_position = Vector2(outerMarginX + cardSlotBaseWidth, outerMarginY) + k*Vector2(0, slotSize.y + cardSlotGapsY) \
					+ j * Vector2(slotSize.x + cardSlotGapsX, 0) + i * Vector2(cardSlotTotalWidth + middleMarginX, 0)
				$CardSlots.add_child(newSlot)
				cardSlotEmpty.append(true)

func ReduceHandSize(amount):
	handSize -= amount

func _on_Card_summon(unitName, slotToSummonAUnit):
	var unitInfo = cardDatabase.DATA[cardDatabase.get(unitName)]
	var path = unitInfo[7]
	var newUnit = load(path).instance()
	newUnit.rect_position = $CardSlots.get_child(slotToSummonAUnit).rect_position
	$Units.add_child(newUnit)
	newUnit.SetCurrentSlot(slotToSummonAUnit)

func SummonAUnit(slotToSummonAUnit, unitName):
	var path = "res://Units/UnitEffects/"+unitName+".tscn"
	print(path)
	var newUnit = load(path).instance()
	newUnit.rect_position = $CardSlots.get_child(slotToSummonAUnit).rect_position
	$Units.add_child(newUnit)
	newUnit.SetCurrentSlot(slotToSummonAUnit)

func PutCardInGraveyard(cardName):
	MoveCardBetweenZones(cardName, cardsInHand, cardsInGraveyard)
#	print("GRAVEYARD'S INHABITANTS: ",playerGraveyard.cardList)

func PutUnitInGraveyard(cardName):
	pass

func MoveCardBetweenZones(card, startZone, endZone):
#	print("STARTZONE BEFORE: ",startZone)
	startZone.erase(card)
	endZone.append(card)
	match endZone:
		cardsInGraveyard:
			print("CARDSINGRAVEYARDMOVEBETWEENZONES: ", card.state)
			card.state = inGraveyard
		cardsInHand:
			card.state = inHand
		cardsInDeck:
			card.state = inDeck
		_:
			print("EEEEEEEEEEEEEEEERROOOOOOOOOOOOOOOR, NO MATCHING STATE FOR ZONE")

#Called when card is moved away from hand
#Reorganizes rest of handhn   
func ReorganizeHand(cardPos):
	for Card in cardsInHand:
		if Card.positionInHand < cardPos:
			Card.positionInHand += 1
			Card.AnimateACard(animTime, Card.rect_position, handCardPosition[Card.positionInHand] - Card.rect_size/2) # Aand animate
			Card.state = inHand
		elif Card.positionInHand > cardPos:
			Card.positionInHand -= 1
			Card.startPos = Card.rect_position # starting position
			Card.targetPos = handCardPosition[Card.positionInHand] - Card.rect_size/2  # target position
			Card.AnimateACard(animTime, Card.rect_position, handCardPosition[Card.positionInHand] - Card.rect_size/2) # Aand animate
			Card.state = inHand

func SummonAnEnemy(slotToSummonAnEnemy):
	var newEnemy = enemy.instance()
	newEnemy.rect_position = $CardSlots.get_child(slotToSummonAnEnemy).rect_position
	newEnemy.cardSlotPos = slotToSummonAnEnemy
	$Enemies.add_child(newEnemy)
	newEnemy.SetCurrentSlot(slotToSummonAnEnemy)

func IncrementAttackCounter():
	attackCounter += 1
	print("attackCounter = ", attackCounter)

func ReShuffleDeck():
	if cardsInGraveyard.size() == 0:
		print("RETURNING NULL FROM RESHUFFLEDECK")
		return 1
	while cardsInGraveyard.size() > 0:
		var cardToMove = cardsInGraveyard[0]
		MoveCardBetweenZones(cardToMove, cardsInGraveyard, cardsInDeck)
	return null

func _on_EndTurn_turnEnded(nextTurnNumber):
	var i = 0
	var tempArrayForCards = []
	for Card in cardsInHand:
		tempArrayForCards.append(Card)
		i += 1
	for Card in tempArrayForCards:
		DiscardCard(Card.positionInHand)
	DrawCard(5)
