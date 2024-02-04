extends Node

'''
Вместилище глобальных переменных
'''

# id -> data ({})
# data <- {"wirangs"}

var character = preload("res://src/Entities/Man.tscn")
var fists = preload("res://src/Weapons/Fists.tscn")
var fireward = preload("res://src/Weapons/FireWard.tscn")
func _ready() -> void: # start game!
	var ui = get_parent().get_node_or_null("Manager/UILayer/UI")
	if ui:
		var man = character.instantiate()
		var weapon = fists.instantiate()
		weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(Stats.WeaponArchiType.Fists)
		print(weapon.weapon_attributes.damage.attribute_value)
		man.character_attributes = Stats.get_random_character_attributes()
		man.attribute_container = Stats.AttributeContainer.new()
		man.attribute_container.current_character = man.character_attributes
		man.attribute_container.current_weapon = weapon.weapon_attributes
		add_child(man)
		man.set_weapon(weapon)
		
		weapon = fists.instantiate()
		weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(Stats.WeaponArchiType.Fists)
		ui.add_item(weapon)
		
		weapon = fireward.instantiate()
		weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(Stats.WeaponArchiType.Fists)
		ui.add_item(weapon)
		
		weapon = fireward.instantiate()
		weapon.weapon_attributes = Stats.get_random_weapon_attributes_architype(Stats.WeaponArchiType.Fists)
		ui.add_item(weapon)
		
		
		ui.call_deferred("add_to_bar", man)
		manager.call_deferred("next_level")
		man.attribute_container.force_update()
	else:
		push_warning("GAME CANNOT BE STARTED")


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.ctrl_pressed and event.keycode == KEY_F12:
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
