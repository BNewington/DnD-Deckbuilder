extends Node

enum CursorType {
	Pointer,
	Hand,
	Disabled,
	TileSelector
}


##Cursor Signals
signal cursor_mode_disabled()
signal cursor_mode_hand()
signal cursor_mode_pointer()
signal show_tile_selector()
signal hide_tile_selector()


##Battle Signals
signal start_battle()
signal start_turn(Unit)


##Card Signals
signal card_hovered(card: CardUI)
signal hover_stopped()
signal card_aiming_started(card: CardUI, tiles: Array[Vector2i])
signal card_aiming_ended(card: CardUI)
signal card_dragging_started(card: CardUI)
signal card_dragging_ended(card: CardUI)
signal card_played(card: Card)
