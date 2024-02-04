class_name Item
extends Node2D
@export var item_type : Game.ItemType = Game.ItemType.any

var base_stats = {}

func update_stats(additional_stats):
	for stat in base_stats:
		pass
