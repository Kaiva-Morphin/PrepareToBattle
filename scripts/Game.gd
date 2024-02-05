extends Node

'''
Вместилище глобальных переменных
'''

# id -> data ({})
# data <- {"wirangs"}
var background_music_val = 0.
var battle_music_val = -50.
func _process(delta: float) -> void:
	match current_state:
		Game.GameState.prepare:
			background_music_val = lerp(background_music_val, 0., delta)
			battle_music_val = lerp(battle_music_val, -50., delta)
		Game.GameState.inbattle:
			background_music_val = lerp(background_music_val, -50., delta)
			battle_music_val = lerp(battle_music_val, 0., delta)
		Game.GameState.game_over:
			background_music_val = lerp(background_music_val, -50., delta)
			battle_music_val = lerp(battle_music_val, -50., delta)
	battle_music_player.volume_db = battle_music_val
	background_music_player.volume_db = background_music_val

var background_music_player
var battle_music_player
var character = preload("res://Entities/Man.tscn")
func _ready() -> void: # start game!
	background_music_player = AudioStreamPlayer.new()
	battle_music_player = AudioStreamPlayer.new()
	
	background_music_player.bus = "Background"
	battle_music_player.bus = "Battle"
	background_music_player.stream = load("res://sounds/background_music.mp3")
	background_music_player.autoplay = true
	battle_music_player.stream = load("res://sounds/battle_music.mp3")
	battle_music_player.autoplay = true
	
	
	
	add_child(background_music_player)
	add_child(battle_music_player)
	var ui = get_parent().get_node_or_null("Manager/UILayer/UI")
	if ui:
		#for i in range(5):
			#var man = manager.get_random_binded_man()
			#man.update_container()
			#add_child(man)
			#ui.call_deferred("add_to_bar", man)
		#for i in range(10):
			#var a = preload("res://armor/HeadArmor.tscn").instantiate().duplicate()
			#a.randomize_texture()
			#a.attributes = Stats.get_random_armor_attributes()
			#ui.add_item(a)
			#var b = preload("res://armor/ChestArmor.tscn").instantiate().duplicate()
			#b.randomize_texture()
			#b.attributes = Stats.get_random_armor_attributes()
			#ui.add_item(b)
			#var c = preload("res://armor/LegsArmor.tscn").instantiate().duplicate()
			#c.randomize_texture()
			#c.attributes = Stats.get_random_armor_attributes()
			#ui.add_item(c)
			#var d = preload("res://accessories/Accessory.tscn").instantiate().duplicate()
			#d.randomize_texture()
			#d.attributes = Stats.get_random_item_attributes()
			#ui.add_item(d)
			#
		#for i in range(10):
			#var w = manager.weapons.pick_random()
			#var weapon = w[0].instantiate().duplicate()
			#weapon.randomize_texture()
			#weapon.attributes = Stats.get_random_weapon_attributes_architype(w[1])
			#ui.add_item(weapon)
		var man = manager.get_random_binded_man()
		man.update_container()
		add_child(man)
		ui.call_deferred("add_to_bar", man)
		manager.call_deferred("next_level")
		
	else:
		push_error("GAME CANNOT BE STARTED")

func game_over():
	pass


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
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
var difficulty_enemy_multipler = 1.5



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
