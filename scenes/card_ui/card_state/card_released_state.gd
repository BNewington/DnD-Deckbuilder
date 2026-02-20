extends CardState

var played: bool

func enter() -> void:
	#HACK for displaying state logic
	card_ui.color.color = Color.DARK_VIOLET
	card_ui.state.text = "RELEASED"
	
	played = false
	
	if not card_ui.targets.is_empty():
		played = true
		#TODO make this actually play the card
		print("Played card for target(s) ",card_ui.targets)
	
	card_ui.queue_free()


func on_input(_event: InputEvent) -> void:
	if played:
		return
	
	transition_requested.emit(self, State.BASE)
