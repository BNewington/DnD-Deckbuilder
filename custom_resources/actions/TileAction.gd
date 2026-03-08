class_name TileAction
extends Resource

@export var player_performed: bool = true ##Set to true if the action is performed by the unit that initiates it
@export var performer_action_id: int ##Only used if player performed is set to false, determines which unit performs instead
@export var target: AreaDef ##Defines the area targeted, and the valid targets within the area, leave blank if the target is self
@export var effects: Array[Effect] #TODO rename Effect to TileEffect
@export var can_cancel_after: bool =  true ##Determines whether the action can be cancelled without discarding the card and spending energy

func requires_aiming() -> bool:
	if target and target.selection != AreaDef.TargetType.AREA:
		return true
	return false
