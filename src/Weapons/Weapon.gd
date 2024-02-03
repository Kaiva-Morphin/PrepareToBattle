class_name Weapon
extends Node2D

var current_target : Entity = null
@export var damage : float = 3.
@export var attack_speed : float = 1.
@export var speed_modificator : float = 1.
@export var attack_range : float = 30


func start_attack(_target): # rename to start_attack
	pass

func on_attack(): # rename to do_attack() || on_attack()
	pass

func stop():
	pass
