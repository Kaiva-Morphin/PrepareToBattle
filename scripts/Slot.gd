class_name Slot
extends Panel

@export var specific_type : Game.ItemType = Game.ItemType.any
@export var wearable_slot : bool = false


func get_item_or_null() -> Item:
	for node in get_children():
		if node is Item:
			return node
	return null



func _make_custom_tooltip(for_text):
	#var label = RichTextLabel.new()
	##RichTextLabel.update_c
	#var font = label.get_theme_font("normal_font")
	##label.text = tooltip_text
	#label.bbcode_enabled = true
	#label.text = "[color=red]red\nred\nzxczxczxc"
	#label.fit_content = true
	#var s = font.get_string_size("red")
	#label.custom_minimum_size = s
	#label.custom_minimum_size.x = font.get_string_size("zxczxczxc").x
	var label = Label.new()
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
	text = for_text + "\n" + text
	label.text = text
	
	return label
