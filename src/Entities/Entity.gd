class_name Entity
extends CharacterBody2D


@export var specialisation : Node2D = null
@export var weapon : Weapon = null



@export var hp : float = 100.
@export var max_hp : float = 100.
@export var speed : float = 50
@export var target : Entity = null

@export var team : Game.Team

var current_state = Game.EntityState.seek

func _ready():
	var color
	match team:
		Game.Team.player:
			self.add_to_group("player")
			color = Color.AQUA
		Game.Team.enemy:
			self.add_to_group("enemy")
			color = Color.PALE_VIOLET_RED
		Game.Team.other:
			self.add_to_group("other")
			color = Color.WHITE
		null:
			color = Color.BLACK
	$EntityLabel.modulate = color
	$UpdateTargetPosition.start()
	$UpdateTargets.start()
	weapon = get_node("Mirror/Weapon").get_child(0)
	if !weapon:
		weapon = preload("res://src/Weapons/Fists.tscn").instantiate()
	_on_state_changed(current_state)



func _on_state_changed(_new_state):
	pass

func take_damage(amount):
	hp -= amount
	if hp <= 0: death()
	update_health()
	_on_take_damage()

func _on_take_damage():
	pass

func _on_update_targets_timeout():
	if Game.manager:
		var new_target = Game.manager.get_closest_oppositive_team_member(self.position, self.team)
		if new_target:
			target = new_target
			if target.position.distance_squared_to(self.position) > weapon.attack_range ** 2:
				current_state = Game.EntityState.seek
				_on_state_changed(current_state)
			_on_state_changed(current_state) # update weapon target
			if target.position.x - self.position.x > 0:
				$Mirror.scale.x = 1
			else:
				$Mirror.scale.x = -1
		else:
			current_state = Game.EntityState.idle
			_on_state_changed(current_state)
		#$UpdateTargets.start()

func _physics_process(_delta): # move torwards target (if state)
	var direction = Vector2.ZERO
	if current_state == Game.EntityState.seek and target and is_instance_valid(target):
		var near = target.position.distance_squared_to(self.position) < weapon.attack_range ** 2
		if near:
			current_state = Game.EntityState.near
			_on_state_changed(current_state)
			if target.position.x - self.position.x > 0:
				$Mirror.scale.x = 1
			else:
				$Mirror.scale.x = -1
		else:
			direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	if direction:
		if direction.x > 0:
			$Mirror.scale.x = 1
		else:
			$Mirror.scale.x = -1
	velocity = direction * speed
	move_and_slide()

func _process(_delta: float) -> void:
	var debug_text = str(self.current_state) + "\n"
	
	if target and is_instance_valid(target):
		debug_text += str(self.target.name) + "\n"
	
	if weapon and is_instance_valid(weapon):
		debug_text += str(self.weapon.attack_range) + "\n"
	
	$DEBUG.text = debug_text

func update_health():
	$EntityLabel/Level/Health.value = hp / max_hp * 100

func _on_update_target_position_timeout():
	if target and is_instance_valid(target):
		$NavigationAgent2D.target_position = target.global_position
	#$UpdateTargetPosition.start()

func death():
	self.queue_free()

