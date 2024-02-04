extends Node

enum Rarity{
	Common,
	Uncommon,
	Rare,
	Awesome,
	Strange,
	Mythical,
}

var weapon_stats = ["Damage", "CritChance", "CritDamage", "AttackRange"]
var character_stats = ["Speed", "Health", "HealthRegen", "AttackSpeed"]
var armor_stats = ["DamageReduction", "Evasion"]



func get_rarity_color(rarity: Rarity):
	match Rarity:
		Rarity.Common: return Color.WHITE
		Rarity.Uncommon: return Color.WEB_GREEN
		Rarity.Rare: return Color.BLUE
		Rarity.Awesome: return Color.GOLD
		Rarity.Strange: return Color.MEDIUM_VIOLET_RED
		Rarity.Mythical: return Color.RED

func get_rarity_char(rarity: Rarity):
	match Rarity:
		Rarity.Common: return "C"
		Rarity.Uncommon: return "U"
		Rarity.Rare: return "R"
		Rarity.Awesome: return "A"
		Rarity.Strange: return "S"
		Rarity.Mythical: return "M"

func get_rarity_string(rarity: Rarity):
	match Rarity:
		Rarity.Common: return "Обычный"
		Rarity.Uncommon: return "Необычный"
		Rarity.Rare: return "Редкий"
		Rarity.Awesome: return "Превосходный"
		Rarity.Strange: return "Странный"
		Rarity.Mythical: return "Мифический"



class Attribure:
	var attribute_name: String
	var displaying_name: String
	var item_origin: Item

var stats_range = {
	
}
