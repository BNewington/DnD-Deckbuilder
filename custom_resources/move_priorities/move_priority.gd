class_name MovePriority
extends Resource

#this resource should take in a group of cells and return the ones that meet a certain criteria

func filter_tiles(_unit: Unit, _tiles: Array[Vector2i]) -> Array[Vector2i]:
	return []


func _get_heroes(unit: Unit) -> Array[Node]:
	var heroes = Navigation.get_units(Navigation.UnitType.Hero)
	var warrior_only: Array[Node] = []
	if unit.status_handler.has_status("taunt"):
		for hero in heroes:
			var hero_stats: HeroStats = hero.stats
			if hero_stats.type == HeroStats.HeroType.Warrior:
				warrior_only.append(hero)
		return warrior_only
	return heroes
