class_name Weapon
extends Item

var current_target : Entity = null

@onready var animation_player = get_node_or_null("AnimationPlayer")


var holder : Entity
var weapon_attributes : Stats.WeaponAttributes
var damage
var crit_damage
var crit_chance
var attack_range
var attack_speed
var lifesteal



func apply_container_stats(container_holder):
	holder = container_holder
	damage = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.damage)
	crit_damage = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.crit_damage)
	crit_chance = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.crit_chance)
	attack_range = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.attack_range)
	attack_speed = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.attack_speed)
	lifesteal = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.lifesteal)
	set_attack_speed(attack_speed)

func _ready():
	pass

func start_attack(target): # rename to start_attack
	if !is_instance_valid(target): target = null; return
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("attack")
		current_target = target

func on_attack():
	pass

func stop():
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("RESET")

func set_attack_speed(new_attack_speed):
	animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.speed_scale = new_attack_speed
