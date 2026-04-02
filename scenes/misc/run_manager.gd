extends Node

@onready var scenes: Array[String] = ["res://scenes/3D/battle/battle.tscn"]
@onready var fade_animation: AnimationPlayer = $FadeLayer/FadeAnimation
@onready var win_screen: Control = $FadeLayer/WinScreen

@export var heroes: Array[HeroStats]

var current_scene: Node


func _ready() -> void:
	Events.battle_won.connect(_on_battle_won)
	heroes = init_hero_stats()
	load_new_scene()
	fade_animation.play("fade_in")

func get_random_scene() -> Node:
	var i = randi_range(0, scenes.size()-1)
	return load(scenes[i]).instantiate()


func _on_battle_won() -> void:
	Events.menu_opened.emit()
	win_screen.show()


func _on_next_button_pressed() -> void:
	win_screen.hide()
	fade_animation.play("fade_out")
	await fade_animation.animation_finished
	
	current_scene.queue_free()


func load_new_scene() -> void:
	current_scene = get_random_scene()
	current_scene.tree_exited.connect(scene_clear)
	add_child(current_scene)
	
	if current_scene is Battle:
		current_scene.start_battle(init_hero_stats())


func scene_clear() -> void:
	if not get_tree():
		return
	var timer = get_tree().create_timer(0.5)
	await timer.timeout
	load_new_scene()
	if not current_scene.is_node_ready():
		await current_scene.ready
	fade_animation.play("fade_in")


func init_hero_stats() -> Array[HeroStats]:
	var stats: Array[HeroStats] = []
	for hero in heroes:
		stats.append(hero.create_instance())
	return stats
