extends CardState

var played: bool

func enter() -> void:
	played = false
	
	if not card_ui.targets.is_empty():
		played = true
		#TODO make this actually play the card
		print("Played card for target(s) ",card_ui.targets)
		card_ui.play()
	


func on_input(_event: InputEvent) -> void:
	if played:
		return
	
	transition_requested.emit(self, State.BASE)
