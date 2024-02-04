
extends Weapon



func on_attack():
	if current_target and is_instance_valid(current_target):
		current_target.take_damage(damage)
		
