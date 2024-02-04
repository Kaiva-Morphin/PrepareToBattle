class_name FireWard
extends Weapon


func on_attack():
	if current_target and is_instance_valid(current_target):
		var projectile = Projectiles.FireBall.duplicate().instantiate()
		projectile.damage = self.damage
		projectile.homing = false
		projectile.speed = 100.
		projectile.target = self.current_target
		Game.manager.add_child(projectile)
		projectile.global_position = self.global_position
		projectile.launch()
