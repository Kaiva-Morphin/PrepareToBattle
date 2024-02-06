extends Node

# id -> data ({})
# data <- {"wirangs"}
var background_music_val = 0.
var battle_music_val = -50.
func _process(delta: float) -> void:
	match current_state:
		GameState.prepare:
			background_music_val = lerp(background_music_val, 0., delta)
			battle_music_val = lerp(battle_music_val, -50., delta)
		GameState.inbattle:
			background_music_val = lerp(background_music_val, -50., delta)
			battle_music_val = lerp(battle_music_val, 0., delta)
		GameState.game_over:
			background_music_val = lerp(background_music_val, -50., delta)
			battle_music_val = lerp(battle_music_val, -50., delta)
	battle_music_player.volume_db = battle_music_val
	background_music_player.volume_db = background_music_val

var background_music_player
var battle_music_player
var character = preload("res://entities/Man.tscn")

func _ready() -> void: # start game!
	current_state = GameState.prepare
	stages_passed = 0
	difficulty = 1
	difficulty_enemy_multipler = 1.
	
	if !background_music_player:
		background_music_player = AudioStreamPlayer.new()
		background_music_player.bus = "Background"
		background_music_player.stream = load("res://sounds/background_music.mp3")
		background_music_player.autoplay = true
		add_child(background_music_player)
	if !battle_music_player:
		battle_music_player = AudioStreamPlayer.new()
		battle_music_player.bus = "Battle"
		battle_music_player.stream = load("res://sounds/battle_music.mp3")
		battle_music_player.autoplay = true
		add_child(battle_music_player)
	
	
	
	
	var ui = get_parent().get_node_or_null("Manager/UILayer/UI")
	if ui:
		var man = manager.get_random_binded_man()
		man.update_container()
		add_child(man)
		ui.call_deferred("add_to_bar", man)
		manager.call_deferred("next_level")
	else:
		push_error("GAME CANNOT BE STARTED")

func reset():
	manager.ui.clear_inventory()
	for e in get_tree().get_nodes_in_group("entity"): e.queue_free()
	for e in get_tree().get_nodes_in_group("projectile"): e.queue_free()
	for e in get_tree().get_nodes_in_group("potion_effect"): e.queue_free()
	await manager.ui.get_node("GAMEOVER/Button").pressed
	manager.ui.get_node("GAMEOVER").hide()
	_ready()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.ctrl_pressed and event.keycode == KEY_F7:
				var i = manager.get_random_potion()
				manager.ui.potion_to_bar(i)
			if event.ctrl_pressed and event.keycode == KEY_F8:
				var i = manager.get_random_accessory()
				manager.ui.add_item(i)
			if event.ctrl_pressed and event.keycode == KEY_F9:
				var i = manager.get_random_armor()
				manager.ui.add_item(i)
			if event.ctrl_pressed and event.keycode == KEY_F10:
				var i = manager.get_random_weapon()
				manager.ui.add_item(i)
			if event.ctrl_pressed and event.keycode == KEY_F11:
				var i = manager.get_random_binded_man()
				manager.ui.add_to_bar(i)
			if event.ctrl_pressed and event.keycode == KEY_F12:
				for e : Entity in get_tree().get_nodes_in_group("entity"):
					if !e.in_inventory:
						match e.team:
							Game.Team.enemy:
								e.queue_free()
				manager.next_level()


var current_state = GameState.prepare
var stages_passed : int = 0
var difficulty = 1
var difficulty_enemy_multipler = 1.



enum GameState{
	prepare,
	inbattle,
	game_over
}

enum Team{
	player,
	enemy,
	other,
}
enum ItemType{
	any,
	weapon,
	head_armor,
	chest_armor,
	leg_armor,
	accsessory
}
enum EntityState{
	idle,
	near,
	seek,
	dead,
}

@onready var manager = get_parent().get_node("Manager")
