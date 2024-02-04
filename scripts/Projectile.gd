class_name Projectile
extends RigidBody2D

@export var pierce : float = 1
@export var target : Entity = null
@export var lifetime : float = 10.
@export var damage : float = 30.
@export var homing : bool = false
@export var speed : float = 50.

func _ready():
	add_to_group("projectiles")

func launch():
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
		if target and is_instance_valid(target) and body == target:
			target.take_damage(damage)
			self.queue_free()


func _on_lifetime_timer_timeout() -> void:
	self.queue_free()
