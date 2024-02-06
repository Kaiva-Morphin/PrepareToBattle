class_name Entity
extends CharacterBody2D

var in_inventory = false

var head_armor : HeadArmor = null
var chest_armor : ChestArmor = null
var legs_armor : LegsArmor = null
var accsessorry1 : Accessory = null
var accsessorry2 : Accessory = null
@export var weapon : Weapon = null

@export var paused := true

@export var target : Entity = null
@export var team : Game.Team

var tornado : Vector2 = Vector2.ZERO


var attributes
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
	$EntityLabel/Level/Label.text = Stats.get_rarity_char(attributes.item_rarity)
	$EntityLabel/Level.self_modulate = Stats.get_rarity_color(attributes.item_rarity)
	$CanvasLayer/HINT.tooltip_text = attribute_container.get_final_stats()

func generate_container():
	attribute_container = Stats.AttributeContainer.new()
	attribute_container.current_character = attributes
	attribute_container.current_weapon = weapon.attributes
	update_container()



func set_weapon(e : Weapon):
	set_weapon_noupdate(e)
	attribute_container.override_weapon_attributes(e.attributes)
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
	$EntityLabel/Level/Health.modulate = color
	animation_player = get_node_or_null("Animation")
	if animation_player:
		animation_player.speed_scale = 0.8 + randf() * 0.4
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


func take_heal(amount):
	current_hp += amount
	update_health()
	_on_heal()

func _on_heal():
	pass

func take_damage(amount):
	current_hp -= amount
	
	var label = Label.new()
	label.scale = Vector2.ONE * 0.5
	label.modulate = Color.RED
	label.set("theme_override_colors/font_outline_color", Color.BLACK)
	label.set("theme_override_constants/outline_size", 4.)
	label.text = str(round(amount))
	var start_pos = self.global_position
	Game.manager.add_child(label)
	label.position = start_pos + Vector2(0., -10.)
	var tween2 = Game.manager.create_tween()
	tween2.tween_property(label, "position", start_pos + Vector2(0., -25.), 1.)
	tween2.connect("finished", func(): label.queue_free())
	
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
			if direction.x > 0.1:
				$Mirror.scale.x = 1
			else:
				$Mirror.scale.x = -1
		velocity = direction * attribute_container.get_attribute_or_null(Stats.AttributeType.speed)
		if tornado != Vector2.ZERO:
			velocity = tornado
			tornado = Vector2.ZERO
		move_and_slide()

func _process(_delta: float) -> void:
	var debug_text = str(self.current_state) + "\n"
	if target and is_instance_valid(target):
		debug_text += str(self.target.name) + "\n"
	if weapon and is_instance_valid(weapon):
		debug_text += str(self.weapon.attack_range) + "\n"
	$DEBUG.text = debug_text

func _on_update_hint_timeout() -> void:
	$CanvasLayer/HINT.position = self.global_position - $CanvasLayer/HINT.size * 0.5
	if Game.manager.get_node("UILayer/UI").is_inventory_open:
		$CanvasLayer/HINT.hide()
	else:
		$CanvasLayer/HINT.show()
	#print($CanvasLayer/HINT.position)

func update_health():
	$EntityLabel/Level/Health.value = current_hp / attribute_container.get_attribute_or_null(Stats.AttributeType.health) * 100

func _on_update_target_position_timeout():
	if target and is_instance_valid(target):
		$NavigationAgent2D.target_position = target.global_position
	#$UpdateTargetPosition.start()

func death():
	self.queue_free()

func _on_regenerate_timeout() -> void:
	current_hp = clamp(current_hp + attribute_container.get_attribute_or_null(Stats.AttributeType.health_regeneration), 0., attribute_container.get_attribute_or_null(Stats.AttributeType.health))

