class_name TileAction
extends Action

@export var player_centered: bool = true 
@export var center_action_id: int ##Only used if player centered is set to false, determines which unit it is centered on instead
@export var player_performed: bool = true ##Set to true if the action is performed by the unit that initiates it
@export var performer_action_id: int = 0##Only used if player performed is set to false, determines which unit performs instead
@export var target: AreaDef ##Defines the area targeted, and the valid targets within the area, leave blank if the target is self
@export var effects: Array[TileEffect] #TODO rename Effect to TileEffect
@export var can_cancel_after: bool =  true ##Determines whether the action can be cancelled without discarding the card and spending energy

func requires_aiming() -> bool:
	if target and target.selection != AreaDef.TargetType.AREA:
		return true
	return false

func is_aoe() -> bool:
	if target and target.selection == AreaDef.TargetType.AREA:
		return true
	return false
