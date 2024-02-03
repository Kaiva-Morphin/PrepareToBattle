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

func _on_take_damage():
	var tween = create_tween()
	
	tween.tween_property($Mirror, "modulate", Color.RED, 0.1)
	tween.connect("finished", func(): $Mirror.modulate = Color.WHITE)
	#$Mirror/Sprite2D.modu

