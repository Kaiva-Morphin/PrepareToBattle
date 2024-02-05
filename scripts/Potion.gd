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
@export var type : PotionType


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
