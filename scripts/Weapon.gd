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

@export var sprite_list : Array[Sprite2D] = []
@export var texture_variant_amount : int = 0
@export var texture_size : int = 24
@export var texture_row : int = 0

func _ready() -> void:
	pass

func randomize_texture():
	var i = randi_range(0, texture_variant_amount - 1)
	for sprite in sprite_list:
		if sprite.texture is AtlasTexture:
			sprite.texture.region = Rect2(Vector2(texture_size * i, texture_size * texture_row), Vector2(texture_size, texture_size))

func apply_container_stats(container_holder):
	holder = container_holder
	damage = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.damage)
	crit_damage = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.crit_damage)
	crit_chance = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.crit_chance)
	attack_range = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.attack_range)
	attack_speed = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.attack_speed)
	lifesteal = container_holder.attribute_container.get_attribute_or_null(Stats.AttributeType.lifesteal)
	set_attack_speed(attack_speed)

func start_attack(target):
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
