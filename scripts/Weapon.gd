class_name Weapon
extends Item

var current_target : Entity = null

@onready var animation_player = get_node_or_null("AnimationPlayer")

var weapon_attributes : Stats.WeaponAttributes
var damage
var crit_damage
var crit_chance
var attack_range
var attack_speed
var lifesteal

func _ready():
	pass

func start_attack(target): # rename to start_attack
	if animation_player:
		animation_player.play("attack")
		current_target = target

func on_attack():
	pass

func stop():
	if animation_player:
		animation_player.play("RESET")

func set_attack_speed(new_attack_speed):
	if animation_player:
		animation_player.speed_scale = new_attack_speed
