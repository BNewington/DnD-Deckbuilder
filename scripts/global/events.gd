extends Node

enum CursorType {
	Pointer,
	Hand,
	Disabled,
	TileSelector
}


##Cursor Signals
signal cursor_mode_disabled
signal cursor_mode_hand
signal cursor_mode_pointer
signal show_tile_selector
signal hide_tile_selector


##Battle Signals
signal start_battle
signal start_turn(Unit)
signal turn_ended(hero: Unit)
signal unit_died(unit: Unit)
signal set_stats(unit: Unit, stats: UnitStats)
signal effect_resolved
signal initiative_hovered(unit: Unit)
signal initiative_hovered_off(unit: Unit)
signal move_complete(unit: Unit)
signal reward_collected(unit: Unit)
signal battle_won
signal unit_hovered(unit: Unit)
signal unit_hovered_off(unit: Unit)
signal request_tile_highlights(tiles: Array[Vector2i], valid_targets: Array[Vector2i])
signal clear_tile_highlights


##Card Signals
signal card_hovered(card: CardUI)
signal hover_stopped
signal card_aiming_started(card: CardUI, tiles: Array[Vector2i], valid_targets: Array[Vector2i])
signal card_aiming_ended(card: CardUI)
signal card_dragging_started(card: CardUI)
signal card_dragging_ended(card: CardUI)
signal card_played(card: Card)
signal update_aoe_highlights(tiles: Array[Vector2i])
signal draw_card(hero_stats: HeroStats)
signal card_reward_confirmed(card: Card)


##Hero Signals
signal hand_drawn
signal hand_discarded(hero: Unit)


##UI Signals
signal menu_opened
signal menu_closed
