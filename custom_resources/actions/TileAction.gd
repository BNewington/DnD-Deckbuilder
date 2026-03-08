class_name TileAction
extends Resource

@export var player_performed: bool = true ##Set to true if the action is performed by the unit that initiates it
@export var performer_action_id: int ##Only used if player performed is set to flase, determines which unit performs instead
@export var effect: Effect #TODO rename Effect to TileEffect
@export var target: AreaDef ##Defines the area targeted, and the valid targets within the area


func execute(performer: Unit) -> Array[Vector2i]:
	return []
