class_name Potion
extends TextureRect

enum PotionType{
	HealPotion,
	LightingPotion,
	PoisonPotion,
	RagePotion,
	SummonPotion,
	TornadoPotion
}

var area_color = {
	PotionType.HealPotion : Color.YELLOW,
	PotionType.LightingPotion : Color.BLUE,
	PotionType.PoisonPotion : Color.LIME_GREEN,
	PotionType.RagePotion : Color.ORANGE_RED,
	PotionType.SummonPotion : Color.WEB_PURPLE,
	PotionType.TornadoPotion : Color.GRAY,
}



@export var type : PotionType
var duration : float = 3
var effect_treshold : float = 0.5
var radius = 40

func _ready() -> void:
	self.add_to_group("potion")


#static func tweening(area):
	#var tween = create_tween()
	#print(tween)
	#tween.tween_property(get_parent().get_node("Sprite"), "energy", 2., 0.5)
	#tween.connect("finished", func(): get_parent().get_node("Sprite").energy = 0.)

func apply_effect():
	var effect = preload("res://src/PotionEffect.tscn").instantiate()
	effect.color = area_color[type]
	effect.type = type
	Game.manager.add_child(effect)
	effect.global_position = self.global_position


func make_heal():
	texture = load("res://src/sprites/Potions/HealPotion.png")



func _make_custom_tooltip(for_text):
	var label = Label.new()
	if type:
		match type:
			PotionType.HealPotion:
				label.text = " ЗЕЛЬЕ ЛЕЧЕНИЯ "
			PotionType.LightingPotion:
				label.text =  " ЗЕЛЬЕ МОЛНИИ "
			PotionType.PoisonPotion:
				label.text =  " ЗЕЛЬЕ ОТРАВЛЕНИЯ "
			PotionType.RagePotion:
				label.text =  " ЗЕЛЬЕ ЯРОСТИ "
			PotionType.SummonPotion:
				label.text =  " ЗЕЛБЕ ПРИЗЫВА "
			PotionType.TornadoPotion:
				label.text =  " ЗЕЛБЕ ТОРНАДО "
	return label
