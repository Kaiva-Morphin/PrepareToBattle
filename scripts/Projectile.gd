class_name Projectile
extends RigidBody2D

@export var pierce_amount : float = 1
@export var target : Entity = null
@export var lifetime : float = 10.
@export var damage : float = 30.
@export var homing : bool = false
@export var speed : float = 50.

var origin_entity: Entity

@export var crit_damage : float = 2.
@export var crit_chance : float = 0.0
@export var true_strike : float = 0.0
@export var lifesteal : float = 0.0
var team : Game.Team

func _ready():
	add_to_group("projectiles")

func launch():
	var anim = get_node_or_null("AnimationPlayer")
	if anim: anim.play("animation")
	var lifetime_timer = Timer.new()
	lifetime_timer.connect("timeout", _on_lifetime_timer_timeout)
	add_child(lifetime_timer)
	lifetime_timer.start(lifetime)
	if target and is_instance_valid(target):
		self.linear_velocity = (target.global_position - self.global_position).normalized() * speed
	

func _physics_process(_delta: float) -> void:
	if homing:
		if target and is_instance_valid(target):
			self.linear_velocity = (target.global_position - self.global_position).normalized() * speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("entity"):
		if team != body.team: # pierce instead pierce_amount
			var d = damage
			if randf() < crit_chance:
				d *= crit_damage
			var evasion = body.attribute_container.get_attribute_or_null(Stats.AttributeType.evasion)
			var reduction = body.attribute_container.get_attribute_or_null(Stats.AttributeType.projectile_damage_reduction)
			var final_damage = d
			if reduction:
				final_damage = d - d * reduction
			if evasion and evasion > 0 and randf() < 1 - evasion :
				if true_strike and randf() < true_strike:
					body.take_damage(final_damage)
					if lifesteal:
						if origin_entity and is_instance_valid(origin_entity):
							origin_entity.take_heal(d * lifesteal)
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
				body.take_damage(final_damage)
				if lifesteal:
					if origin_entity and is_instance_valid(origin_entity):
						origin_entity.take_heal(d * lifesteal)
			if round(pierce_amount) - 1 > 0:
				pierce_amount -= 1
			else:
				self.queue_free()


func _on_lifetime_timer_timeout() -> void:
	self.queue_free()
