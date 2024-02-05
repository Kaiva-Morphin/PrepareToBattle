class_name Entity
extends CharacterBody2D

var in_inventory = false

@export var weapon : Weapon = null

@export var paused := true

@export var target : Entity = null
@export var team : Game.Team
var character_attributes
var attribute_container

var current_hp

@onready var collision = get_node("Collision")
var current_state = Game.EntityState.seek

@onready var animation_player = get_node_or_null("Animation")

func reset():
	self.pause()
	target = null
	current_state = Game.EntityState.seek
	current_hp = attribute_container.get_attribute_or_null(Stats.AttributeType.health)
	update_health()
	weapon.stop()
	if animation_player:
		animation_player.play("RESET")

func update_container():
	attribute_container.force_update()
	current_hp = attribute_container.get_attribute_or_null(Stats.AttributeType.health)
	update_health()
	weapon.apply_container_stats(self)
	$EntityLabel/Level/Label.text = Stats.get_rarity_char(character_attributes.item_rarity)

func generate_container():
	attribute_container = Stats.AttributeContainer.new()
	attribute_container.current_character = character_attributes
	attribute_container.current_weapon = weapon.weapon_attributes
	attribute_container.force_update()
	current_hp = attribute_container.get_attribute_or_null(Stats.AttributeType.health)
	update_health()
	weapon.apply_container_stats(self)
	$EntityLabel/Level/Label.text = Stats.get_rarity_char(character_attributes.item_rarity)

func set_weapon(e : Weapon):
	set_weapon_noupdate(e)
	attribute_container.override_weapon_attributes(e.weapon_attributes)
	weapon.apply_container_stats(self)

func set_weapon_noupdate(e : Weapon):
	for c in $Mirror/Weapon.get_children():
		$Mirror/Weapon.remove_child(c)
		c.queue_free()
	weapon = e
	$Mirror/Weapon.add_child(e)
	


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
	if !paused:
		init()

func pause():
	paused = true
	$Walk.playing = false
	$UpdateTargetPosition.stop()
	$UpdateTargets.stop()

func unpause():
	paused = false
	init()

func init():
	$UpdateTargetPosition.start()
	$UpdateTargets.start()
	weapon = get_node("Mirror/Weapon").get_child(0)
	_on_state_changed(current_state)

func state_sounds(state):
	match state:
		Game.EntityState.seek:
			if !$Walk.playing:
				$Walk.playing = true
				$Walk.pitch_scale = .9 + randf() * 0.2
				$Walk.volume_db = -0.3 + randf() * 0.6
		_:
			if $Walk.playing:
				$Walk.playing = false

func _on_state_changed(_new_state):
	pass



func take_damage(amount):
	current_hp -= amount
	if current_hp <= 0: death()
	update_health()
	_on_take_damage()

func _on_take_damage():
	pass



func _on_update_targets_timeout():
	if Game.manager:
		var new_target = Game.manager.get_closest_oppositive_team_member(self.position, self.team)
		if new_target:
			target = new_target
			if target.position.distance_squared_to(self.position) > attribute_container.get_attribute_or_null(Stats.AttributeType.attack_range) ** 2:
				current_state = Game.EntityState.seek
				state_sounds(current_state)
				_on_state_changed(current_state)
			state_sounds(current_state)
			_on_state_changed(current_state) # update weapon target
			if target.position.x - self.position.x > 0:
				$Mirror.scale.x = 1
			else:
				$Mirror.scale.x = -1
		else:
			current_state = Game.EntityState.idle
			state_sounds(current_state)
			_on_state_changed(current_state)
		#$UpdateTargets.start()

func _physics_process(_delta): # move torwards target (if state)
	if !paused:
		var direction = Vector2.ZERO
		if current_state == Game.EntityState.seek and target and is_instance_valid(target):
			var near = target.position.distance_squared_to(self.position) < attribute_container.get_attribute_or_null(Stats.AttributeType.attack_range) ** 2
			if near:
				current_state = Game.EntityState.near
				state_sounds(current_state)
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
		velocity = direction * attribute_container.get_attribute_or_null(Stats.AttributeType.speed)
		move_and_slide()

func _process(_delta: float) -> void:
	var debug_text = str(self.current_state) + "\n"
	if target and is_instance_valid(target):
		debug_text += str(self.target.name) + "\n"
	if weapon and is_instance_valid(weapon):
		debug_text += str(self.weapon.attack_range) + "\n"
	$DEBUG.text = debug_text

func update_health():
	$EntityLabel/Level/Health.value = current_hp / attribute_container.get_attribute_or_null(Stats.AttributeType.health) * 100

func _on_update_target_position_timeout():
	if target and is_instance_valid(target):
		$NavigationAgent2D.target_position = target.global_position
	#$UpdateTargetPosition.start()

func death():
	self.queue_free()

func _on_regenerate_timeout() -> void:
	current_hp += attribute_container.get_attribute_or_null(Stats.AttributeType.health_regeneration)
