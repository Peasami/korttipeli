extends MarginContainer

var currentHealth
var enemyAttack = 2
var maxHealth = 10
var cardSlotPos
onready var slotPos
var CardSlots
var possibleAttackSlots = []


# Called when the node enters the scene tree for the first time.
func _ready():
	currentHealth = maxHealth
	ConnectToEndTurn()
	UpdateStats()
	CheckPossibleAttackSlots()
	Attack()

func _process(delta):
	if Input.is_action_just_released("ui_left"):
		Attack()


func ChangeHealth(amount):
	currentHealth -= amount
	$VBoxContainer/HPNumber/Label.text = str(currentHealth)
	if currentHealth <= 0:
		DIE()

func DIE():
	$Tween.interpolate_property($'.', 'rect_position', 
		rect_position, Vector2(0, 0), 0.2,
		Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$Tween.start()

func CheckPossibleAttackSlots():
	var availableSlots = floor(cardSlotPos / 4) - 1
	possibleAttackSlots.append(cardSlotPos - 4)
	for i in availableSlots:
		possibleAttackSlots.append(possibleAttackSlots[i] - 4)
	print("possibleAttackSlots: ", possibleAttackSlots)

func Attack():
#	var CardSlots = $'../../CardSlots'
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	for i in possibleAttackSlots:
#		var childCard = CardSlots.get_child(i)
		if cardSlotEmpty[i] == false:
			var UnitsInPlay = $'../../Units'
			for Unit in UnitsInPlay.get_children():
				if Unit.currentSlotNumber == i:
					Unit.DamageTaken(enemyAttack)
					break

func SetCurrentSlot(number):
	cardSlotPos = number
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	cardSlotEmpty[cardSlotPos] = false
	print("CurrentSlotNumber: ", cardSlotPos)

func TakeDamage(amount):
	currentHealth -= amount
	UpdateStats()

func UpdateStats():
	$VBoxContainer/HPNumber/Label.text = str(currentHealth)

func ConnectToEndTurn():
	var endTurn = $'../../EndTurn'
	endTurn.connect("turnEnded", self, "_on_EndTurn_turnEnded")

func _on_EndTurn_turnEnded(nextTurnNumber):
	Attack()
