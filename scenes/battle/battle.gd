extends Node2D

var warrior_run_card = preload("uid://cql3oentr77yy")
var warrior_strike_card = preload("uid://cxn8jc3q4tmel")

func _ready() -> void:
	Navigation.init_level($GroundTiles)
	Events.start_battle.emit()
	warrior_run_card.unit = $Unit
	warrior_strike_card.unit = $Unit
	#HACK to start turn
	$Unit.start_turn()
