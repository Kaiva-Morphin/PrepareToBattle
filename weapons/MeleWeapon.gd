extends Weapon





func on_attack():
	if current_target and is_instance_valid(current_target):
		var d = damage
		if randf() < crit_chance:
			d *= crit_damage
		var evasion = current_target.attribute_container.get_attribute_or_null(Stats.AttributeType.evasion)
		var true_strike = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.true_strike)
		var lifesteal_val = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.lifesteal)
		var mele_reduction = current_target.attribute_container.get_attribute_or_null(Stats.AttributeType.mele_damage_reduction)
		var final_damage = d
		if mele_reduction:
			final_damage = d - d * mele_reduction
		if evasion and evasion > 0 and randf() < 1 - evasion :
			if true_strike and randf() < true_strike:
				current_target.take_damage(final_damage)
				if lifesteal_val:
					holder.current_hp += d * lifesteal_val
					holder.current_hp = clamp(holder.current_hp, -1, holder.attribute_container.get_attribute_or_null(Stats.AttributeType.health))
					holder.update_health()
			else:
				var label = Label.new()
				label.scale = Vector2.ONE * 0.5
				label.modulate = Color.FLORAL_WHITE
				label.set("theme_override_colors/font_outline_color", Color.BLACK)
				label.set("theme_override_constants/outline_size", 4.)
				label.text = "miss!"
				var start_pos = self.global_position
				Game.manager.add_child(label)
				label.position = start_pos + Vector2(0., -10.)
				var tween2 = Game.manager.create_tween()
				tween2.tween_property(label, "position", start_pos + Vector2(0., -25.), 1.)
				tween2.connect("finished", func(): label.queue_free())
		else:
			current_target.take_damage(final_damage)
			if lifesteal_val:
				holder.current_hp += d * lifesteal_val
				holder.current_hp = clamp(holder.current_hp, -1, holder.attribute_container.get_attribute_or_null(Stats.AttributeType.health))
				holder.update_health()
