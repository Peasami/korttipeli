extends TextureButton

var deckSize = INF


func _ready():
#	rect_scale = $'../../'.cardScale # Look 2 directories up (in Playspace.)
	#Does nothing??
	return
	


func _gui_input(event):
	if Input.is_action_just_released("left_click"):
		if deckSize > 0:
			deckSize = $'../../'.DrawCard()  # Calls DrawCard func, which also returns size of deck
			if deckSize == 0:
				disabled = true
