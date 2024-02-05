extends Weapon





func on_attack():
	if current_target and is_instance_valid(current_target):
		var d = damage
		if randf() < crit_chance:
			d *= crit_damage
		var e = current_target.attribute_container.get_attribute_or_null(Stats.AttributeType.evasion)
		var true_strike = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.true_strike)
		var lifesteal_val = holder.attribute_container.get_attribute_or_null(Stats.AttributeType.lifesteal)
		var mele_reduction = current_target.attribute_container.get_attribute_or_null(Stats.AttributeType.mele_damage_reduction)
		var final_damage = d
		if mele_reduction:
			final_damage = d - d * mele_reduction
		if e and randf() < e:
			if true_strike and randf() < true_strike:
				current_target.take_damage(final_damage)
				if lifesteal_val:
					holder.current_hp += d * lifesteal_val
					holder.current_hp = clamp(holder.current_hp, -1, holder.attribute_container.get_attribute_or_null(Stats.AttributeType.health))
					holder.update_health()
			else:
				pass # miss!
		else:
			current_target.take_damage(final_damage)
			if lifesteal_val:
				holder.current_hp += d * lifesteal_val
				holder.current_hp = clamp(holder.current_hp, -1, holder.attribute_container.get_attribute_or_null(Stats.AttributeType.health))
				holder.update_health()
