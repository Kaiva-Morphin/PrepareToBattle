class_name Weapon
extends Item

var current_target : Entity = null
@export var damage : float = 3.
@export var attack_speed : float = 1.
@export var speed_modificator : float = 1.
@export var attack_range : float = 30

@onready var animation_player = get_node_or_null("AnimationPlayer")

func start_attack(target): # rename to start_attack
	if animation_player:
		animation_player.play("attack")
		current_target = target

func on_attack(): # rename to do_attack() || on_attack()
	pass

func stop():
	if animation_player:
		animation_player.play("RESET")

func set_attack_speed(new_attack_speed): # rename to do_attack() || on_attack()
	if animation_player:
		animation_player.speed_scale = new_attack_speed
