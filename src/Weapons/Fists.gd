class_name Fists
extends Weapon

func _ready() -> void:
	damage = 10.
	attack_speed = 1.
	speed_modificator = 1.
	attack_range = 30

func start_attack(target):
	$Animation.play("attack")
	current_target = target

func stop():
	$Animation.play("RESET")

func on_attack():
	if current_target and is_instance_valid(current_target):
		current_target.take_damage(damage)
