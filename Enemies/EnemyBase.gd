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

func CheckOccupiedSlots(slotsToCheck):
	var slotsWithUnit = []
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	for i in slotsToCheck:
		if cardSlotEmpty[i] == false:
			slotsWithUnit.append(i)
	return slotsWithUnit


func Attack():
#	var CardSlots = $'../../CardSlots'
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	var slotsWithUnit = CheckOccupiedSlots(possibleAttackSlots)
	if slotsWithUnit.empty() == true:
		return
	var firstTarget = slotsWithUnit.max()
	var UnitsInPlay = $'../../Units'
	for i in UnitsInPlay.get_children():
		if i.currentSlotNumber == firstTarget:
			i.DamageTaken(enemyAttack)
			break


func SetCurrentSlot(number):
	cardSlotPos = number
	var cardSlotEmpty = $'../../'.cardSlotEmpty
	cardSlotEmpty[cardSlotPos] = false

func TakeDamage(amount):
	currentHealth -= amount
	UpdateStats()
	if currentHealth <= 0:
		KillUnit()

func UpdateStats():
	$VBoxContainer/HPNumber/Label.text = str(currentHealth)

func ConnectToEndTurn():
	var endTurn = $'../../EndTurn'
	endTurn.connect("turnEnded", self, "_on_EndTurn_turnEnded")

func _on_EndTurn_turnEnded(nextTurnNumber):
	Attack()

func KillUnit():
	pass
