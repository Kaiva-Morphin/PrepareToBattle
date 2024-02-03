class_name FireWard
extends Weapon

func start_attack(target):
	$Animation.play("attack")
	current_target = target

func stop():
	$Animation.play("RESET")

func on_attack():
	if current_target and is_instance_valid(current_target):
		var proj = Projectiles.FireBall.duplicate().instantiate()
		proj.damage = 1#self.damage
		proj.homing = false
		proj.speed = 100.
		proj.target = self.current_target
		Game.manager.add_child(proj)
		proj.global_position = self.global_position
		proj.launch()
