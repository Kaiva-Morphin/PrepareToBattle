extends Entity

var prev_state = null
func _on_state_changed(new_state):
	#$"Animation".play("RESET")
	match new_state:
		Game.EntityState.idle:
			$"Animation".play("Idle")
			weapon.stop()
		Game.EntityState.near:
			$"Animation".play("Idle")
			weapon.start_attack(target)
		Game.EntityState.seek:
			$"Animation".play("Walk")
			weapon.stop()
	prev_state = new_state


func set_armor_head(e : HeadArmor):
	for c in $Mirror/Sprite/Head/HeadArmor.get_children():
		$Mirror/Sprite/Head/HeadArmor.remove_child(c)
		c.queue_free()
	head_armor = e
	$Mirror/Sprite/Head/HeadArmor.add_child(e)
	attribute_container.override_armor_head_attributes(e.armor_attributes)

func set_armor_chest(e : ChestArmor):
	for c in $Mirror/Sprite/Body.get_children():
		$Mirror/Sprite/Body.remove_child(c)
		c.queue_free()
	chest_armor = e
	$Mirror/Sprite/Body.add_child(e)
	attribute_container.override_armor_chest_attributes(e.armor_attributes)

func set_armor_legs(e : LegsArmor):
	for c in $Mirror/Sprite/Lleg.get_children():
		$Mirror/Sprite/Lleg.remove_child(c)
		c.queue_free()
	for c in $Mirror/Sprite/Rleg.get_children():
		$Mirror/Sprite/Rleg.remove_child(c)
		c.queue_free()
	for c in $Mirror/Sprite/HiddenLegs.get_children():
		$Mirror/Sprite/HiddenLegs.remove_child(c)
		c.queue_free()
	
	legs_armor = e
	$Mirror/Sprite/HiddenLegs.add_child(e)
	var left = e.get_node("Sprite2D").duplicate()
	left.position = Vector2(-1, 0)
	$Mirror/Sprite/Lleg.add_child(left)
	var right = e.get_node("Sprite2D").duplicate()
	right.position = Vector2(5, 0)
	$Mirror/Sprite/Rleg.add_child(right)
	attribute_container.override_armor_legs_attributes(e.armor_attributes)

func set_accessory1(e : Accessory):
	for c in $Mirror/Sprite/Head/Accessory1.get_children():
		$Mirror/Sprite/Head/Accessory1.remove_child(c)
		c.queue_free()
	accsessorry1 = e
	$Mirror/Sprite/Head/Accessory1.add_child(e)
	attribute_container.override_accessory1_attributes(e.attributes)

func set_accessory2(e : Accessory):
	for c in $Mirror/Sprite/Head/Accessory2.get_children():
		$Mirror/Sprite/Head/Accessory2.remove_child(c)
		c.queue_free()
	accsessorry2 = e
	$Mirror/Sprite/Head/Accessory2.add_child(e)
	attribute_container.override_accessory2_attributes(e.attributes)




func _on_take_damage():
	var tween = create_tween()
	tween.tween_property($Mirror, "modulate", Color.RED, 0.1)
	tween.connect("finished", func(): $Mirror.modulate = Color.WHITE)
	#$Mirror/Sprite2D.modu

func _on_heal():
	var tween = create_tween()
	tween.tween_property($Mirror, "modulate", Color.YELLOW, 0.1)
	tween.connect("finished", func(): $Mirror.modulate = Color.WHITE)
	#$Mirror/Sprite2D.modu
