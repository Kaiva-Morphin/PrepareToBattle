class_name Slot
extends Panel

@export var specific_type : Game.ItemType = Game.ItemType.any
@export var wearable_slot : bool = false
func _ready() -> void:
	self.tooltip_text = "[empty]"

func get_item_or_null() -> Item:
	for node in get_children():
		if node is Item:
			return node
	return null



func _make_custom_tooltip(for_text):
	var label = Label.new()
	#label.text = tooltip_text
	var text = ""
	var item = get_item_or_null()
	if item:
		match item.item_type:
			Game.ItemType.any:
				text = "[???]"
			Game.ItemType.weapon:
				text = "[weapon]"
			Game.ItemType.head_armor:
				text = "[head_armor]"
			Game.ItemType.chest_armor:
				text = "[chest_armor]"
			Game.ItemType.leg_armor:
				text = "[leg_armor]"
			Game.ItemType.accsessory:
				text = "[accsessory]"
	else:
		match specific_type:
			Game.ItemType.any:
				text = "[empty slot]"
			Game.ItemType.weapon:
				text = "[weapon slot]"
			Game.ItemType.head_armor:
				text = "[head_armor slot]"
			Game.ItemType.chest_armor:
				text = "[chest_armor slot]"
			Game.ItemType.leg_armor:
				text = "[leg_armor slot]"
			Game.ItemType.accsessory:
				text = "[accsessory slot]"
	
	label.text = text
	return label
