extends Node

'''
Вместилище глобальных переменных
'''

# id -> data ({})
# data <- {"wirangs"}

var character = preload("res://Entities/Man.tscn")
func _ready() -> void: # start game!
	var ui = get_parent().get_node_or_null("Manager/UILayer/UI")
	if ui:
		for i in range(5):
			var man = manager.get_random_binded_man()
			man.update_container()
			add_child(man)
			ui.call_deferred("add_to_bar", man)
		for i in range(10):
			var a = preload("res://armor/HeadArmor.tscn").instantiate().duplicate()
			a.randomize_texture()
			a.armor_attributes = Stats.get_random_armor_attributes()
			ui.add_item(a)
			var b = preload("res://armor/ChestArmor.tscn").instantiate().duplicate()
			b.randomize_texture()
			b.armor_attributes = Stats.get_random_armor_attributes()
			ui.add_item(b)
			var c = preload("res://armor/LegsArmor.tscn").instantiate().duplicate()
			c.randomize_texture()
			c.armor_attributes = Stats.get_random_armor_attributes()
			ui.add_item(c)
			var d = preload("res://accessories/Accessory.tscn").instantiate().duplicate()
			d.randomize_texture()
			d.attributes = Stats.get_random_item_attributes()
			ui.add_item(d)
			
		for i in range(10):
			var w = manager.weapons.pick_random()
			var weapon = w[0].instantiate().duplicate()
			weapon.randomize_texture()
			weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(w[1])
			weapon.weapon_attributes.attack_speed.attribute_value = 100.
			ui.add_item(weapon)
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

var stage : int = 0
var difficulty = 1
var difficulty_enemy_multipler = 1.5



enum GameState{
	prepare,
	inbattle
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
