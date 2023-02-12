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
const playerHand = preload("res://Cards/PlayerHand.gd")
const cardSlot = preload("res://Cards/CardSlot.tscn")
const playerGraveyard = preload("res://Cards/PlayerGraveyard.gd")
var cardDatabase = preload("res://Cards/CardDatabase.gd")

onready var centerOfHand = Vector2(512, 500)
var cardsInHand = []

const animTime = 0.3

var cardSelected = []
onready var deckSize = playerHand.cardList.size() # decksize is hand's size
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
	
	
	#Makes grid of slots
	# [0] [4]  [8] [12]   [16] [20] [24] [28]
	# [1] [5]  [9] [13]   [17] [21] [25] [29]
	# [2] [6] [10] [14]   [18] [22] [26] [30]
	# [3] [7] [11] [15]   [19] [23] [27] [31]
	
	for i in range(2):
		for j in range(numberOfColumns):
			for k in range(numberOfRows):
				var newSlot = cardSlot.instance()
				newSlot.rect_scale = cardSlotScale
				newSlot.rect_position = Vector2(outerMarginX + cardSlotBaseWidth, outerMarginY) + k*Vector2(0, slotSize.y + cardSlotGapsY) \
					+ j * Vector2(slotSize.x + cardSlotGapsX, 0) + i * Vector2(cardSlotTotalWidth + middleMarginX, 0)
				$CardSlots.add_child(newSlot)
				cardSlotEmpty.append(true)
	
#	var artifacts = load("res://PlayerStats.CurrentArtifacts.gd")
	
	SummonAnEnemy(22)
#	SummonAUnit(12, "GiantDad")

func DrawCard():
	if deckSize == 0:
		ReShuffleDeck()
		return
	
	handSize += 1 # handsize is bigger
	cardSelected = randi() % deckSize   # Generates random number from deck size
	
	var cardName = playerHand.cardList[cardSelected]   # newCard's name is random from hand with int carSelected
	var cardInfo = cardDatabase.DATA[cardDatabase.get(cardName)]
	var path = cardInfo[6]
	var newCard = load(path).instance()
	newCard.positionInHand = 4 + (handSize - 1)         # Increase first number if max hand size grows
	newCard.rect_size = cardSize # newCard scale (default scale is (1, 1))
	
	
	# reorganize cards already in hand
	for Card in $Cards.get_children():
		if Card.state == inHand:
			Card.positionInHand -= 1 # new position in hand
			Card.AnimateACard(animTime, Card.rect_position, handCardPosition[Card.positionInHand] - Card.rect_size/2) # Aand animate
			Card.state = inHand
			print("PositionInHan: ", Card.positionInHand)
	$Cards.add_child(newCard)      # child of Cards
	
	newCard.AnimateACard(animTime, $PlayerDeck.position - newCard.rect_size/2, handCardPosition[newCard.positionInHand] - newCard.rect_size/2) # Animate card to hand
	newCard.state = inHand
	
	playerHand.cardList.erase(playerHand.cardList[cardSelected])   # Remove from cardList a var with cardSeleted values
	deckSize -= 1  # reduce deckSize
	
	if newCard.cardType == "Unit":
		newCard.connect("summon_unit", self, "_on_Card_summon")
	
	return deckSize


func _on_Card_summon(unitName, slotToSummonAUnit):
	var unitInfo = cardDatabase.DATA[cardDatabase.get(unitName)]
	var path = unitInfo[7]
	var newUnit = load(path).instance()
	newUnit.rect_position = $CardSlots.get_child(slotToSummonAUnit).rect_position
	$Units.add_child(newUnit)
	newUnit.SetCurrentSlot(slotToSummonAUnit)

func SummonAUnit(slotToSummonAUnit, unitName):
	var unitInfo = cardDatabase.DATA[cardDatabase.get(unitName)]
	var path = unitInfo[7]
	var newUnit = load(path).instance()
	newUnit.rect_position = $CardSlots.get_child(slotToSummonAUnit).rect_position
	newUnit.SetCurrentSlot(slotToSummonAUnit)
	$Units.add_child(newUnit)

func PutCardInGraveyard(cardName):
	playerGraveyard.cardList.append(cardName)
	print("GRAVEYARD'S INHABITANTS: ",playerGraveyard.cardList)



#Called when card is moved away from hand
#Reorganizes rest of handhn   
func ReorganizeHand(cardPos):
	handSize -= 1
	for Card in $Cards.get_children():
		if Card.state == inHand:
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
	var graveyardSize = playerGraveyard.cardList.size()
	print("SHUFFLESHUFFLE", graveyardSize)
	for i in graveyardSize:
		print("Shuffling Graveyard:", i)
	pass
