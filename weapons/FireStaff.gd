extends Weapon

func on_attack():
	if current_target and is_instance_valid(current_target):
		var projectile = preload("res://weapons/FireBall.tscn").instantiate()
		projectile.damage = self.damage
		projectile.homing = false
		projectile.speed = 70.
		projectile.origin_entity = self.holder
		projectile.team = self.holder.team
		var speed_mod = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.projectile_speed)
		if speed_mod: projectile.speed *= speed_mod
		var pierce_mod = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.pierce)
		var true_strike = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.true_strike)
		var lifesteal = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.lifesteal)
		if lifesteal: projectile.lifesteal += lifesteal
		if true_strike: projectile.true_strike = true_strike
		if pierce_mod: projectile.pierce_amount *= pierce_mod
		projectile.target = self.current_target
		Game.manager.add_child(projectile)
		projectile.global_position = $Sprite2D/SpawnPoint.global_position
		projectile.launch()
