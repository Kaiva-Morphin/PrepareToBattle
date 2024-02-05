extends Node

'''
per base attrib:
	base ->
	base = base_distribution(base) ->
	attribute = rarity_distribution(attribute)
'''


enum Rarity{
	Common,
	Uncommon,
	Rare,
	Awesome,
	Strange,
	Mythical,
}

var rarity_rolls = 1
func get_random_rarity() -> Rarity:
	var best_rarity = 0
	for roll in rarity_rolls:
		if randf() > 0.5:
			best_rarity = max(best_rarity, 1)
			if randf() > 0.5:
				best_rarity = max(best_rarity, 2)
				if randf() > 0.5:
					best_rarity = max(best_rarity, 3)
					if randf() > 0.5:
						best_rarity = max(best_rarity, 4)
						if randf() > 0.5:
							best_rarity = max(best_rarity, 5)
	match best_rarity:
		1: return Rarity.Uncommon
		2: return Rarity.Rare
		3: return Rarity.Awesome
		4: return Rarity.Strange
		5: return Rarity.Mythical
		_: return Rarity.Common
	#var val = randf_range(0., 100.)
	#if val < 45. : return Rarity.Common
	#if val < 71. : return Rarity.Uncommon
	#if val < 88. : return Rarity.Rare
	#if val < 96. : return Rarity.Awesome
	#if randf() > 0.75:
		#return Rarity.Strange
	#else:
		#return Rarity.Mythical
	
func get_rarity_color(rarity: Rarity):
	match rarity:
		Rarity.Common: return Color.WHITE
		Rarity.Uncommon: return Color.WEB_GREEN
		Rarity.Rare: return Color.BLUE
		Rarity.Awesome: return Color.GOLD
		Rarity.Strange: return Color.MEDIUM_VIOLET_RED
		Rarity.Mythical: return Color.RED

func get_rarity_char(rarity: Rarity):
	match rarity:
		Rarity.Common: return "C"
		Rarity.Uncommon: return "U"
		Rarity.Rare: return "R"
		Rarity.Awesome: return "A"
		Rarity.Strange: return "S"
		Rarity.Mythical: return "M"

func get_rich_rarity_string(rarity: Rarity) -> String:
	match rarity:
		Rarity.Common: return "[color=WHITE]Обычный[/color]"
		Rarity.Uncommon: return "[color=WEB_GREEN]Необычный[/color]"
		Rarity.Rare: return "[color=BLUE]Редкий[/color]"
		Rarity.Awesome: return "[color=GOLD]Превосходный[/color]"
		Rarity.Strange: return "[color=MEDIUM_VIOLET_RED]Странный[/color]"
		Rarity.Mythical: return "[color=RED]Мифический[/color]"
	return ""

func get_rarity_string(rarity: Rarity) -> String:
	match rarity:
		Rarity.Common: return "Обычный"
		Rarity.Uncommon: return "Необычный"
		Rarity.Rare: return "Редкий"
		Rarity.Awesome: return "Превосходный"
		Rarity.Strange: return "Странный"
		Rarity.Mythical: return "Мифический"
	return ""

enum AttributeType{
	# character
	health,
	health_regeneration,
	speed,
	# weapon
	damage,
	lifesteal,
	attack_speed,
	crit_chance,
	crit_damage,
	attack_range,
	true_strike,
	# armor
	evasion,
	mele_damage_reduction,
	projectile_damage_reduction,
	# projectile
	pierce,
	projectile_speed,
}

func get_base_attribute_value_for_multiply(type: AttributeType) -> float:
	match type:
		AttributeType.health: return 100
		AttributeType.health_regeneration: return 1
		AttributeType.speed: return 50
		AttributeType.damage: return 10
		AttributeType.lifesteal: return 0.01 # %
		AttributeType.attack_speed: return 1.
		AttributeType.crit_chance: return 0.01
		AttributeType.crit_damage: return 0.01
		AttributeType.attack_range: return 50
		AttributeType.true_strike: return 0.01
		AttributeType.evasion: return 1
		AttributeType.mele_damage_reduction: return 0.01
		AttributeType.projectile_damage_reduction: return 0.01
		AttributeType.pierce: return 1
		AttributeType.projectile_speed: return 100
	return 0


const AllAttributeTypes : Array[AttributeType] = [
	AttributeType.health,
	AttributeType.health_regeneration,
	AttributeType.speed,
	AttributeType.damage,
	AttributeType.lifesteal,
	AttributeType.attack_speed,
	AttributeType.crit_chance,
	AttributeType.crit_damage,
	AttributeType.attack_range,
	AttributeType.true_strike,
	AttributeType.evasion,
	AttributeType.mele_damage_reduction,
	AttributeType.projectile_damage_reduction,
	AttributeType.pierce,
	AttributeType.projectile_speed,
]

func get_attribute_string(attribute_type: AttributeType):
	match attribute_type:
		AttributeType.health: return "Здоровье"
		AttributeType.health_regeneration: return "Регенерация"
		AttributeType.speed: return "Скорость"
		AttributeType.damage: return "Урон"
		AttributeType.lifesteal: return "Вампиризм"
		AttributeType.attack_speed: return "Скорость Атаки"
		AttributeType.crit_chance: return "Крит. Шанс"
		AttributeType.crit_damage: return "Крит. Урон"
		AttributeType.attack_range: return "Дальность Атаки"
		AttributeType.true_strike: return "Шанс не промахнуться"
		AttributeType.evasion: return "Шанс увернуться"
		AttributeType.mele_damage_reduction: return "Уменьшение ближнего урона"
		AttributeType.projectile_damage_reduction: return "Уменьшение дальнего урона"
		AttributeType.pierce: return "Пробивание у снарядов"
		AttributeType.projectile_speed: return "Скорость снарядов"

func get_random_attribute_type() -> AttributeType:
	return AllAttributeTypes.pick_random()

var CharacterAttribute := {
	AttributeType.health: null,
	AttributeType.health_regeneration: null,
	AttributeType.speed: null,
}

var WeaponAttribute := {
	AttributeType.damage: null,
	AttributeType.lifesteal: null,
	AttributeType.attack_speed: null,
	AttributeType.true_strike: null,
	AttributeType.crit_chance: null,
	AttributeType.crit_damage: null,
	AttributeType.attack_range: null,
}

var ArmorAttribute := {
	AttributeType.evasion: null,
	AttributeType.mele_damage_reduction: null,
	AttributeType.projectile_damage_reduction: null,
}

var ProjectileAttribute := {
	AttributeType.pierce: null,
	AttributeType.projectile_speed: null,
}

var RarityBaseDistributions := {
	Stats.Rarity.Common:   ValueDistribution.new(80. / 100., 140. / 100.),
	Stats.Rarity.Uncommon: ValueDistribution.new(140. / 100., 190. / 100.),
	Stats.Rarity.Rare:     ValueDistribution.new(190. / 100., 210. / 100.),
	Stats.Rarity.Awesome:  ValueDistribution.new(210. / 100., 240. / 100.),
	Stats.Rarity.Strange:  ValueDistribution.new(100. / 100., 300. / 100.),
	Stats.Rarity.Mythical: ValueDistribution.new(240. / 100., 260. / 100.),
}

var RarityNumberOfPositiveSubStatsDistribution := {
	Stats.Rarity.Common: ValueDistribution.new(0., 1.),
	Stats.Rarity.Uncommon: ValueDistribution.new(1., 2.),
	Stats.Rarity.Rare: ValueDistribution.new(1., 3.),
	Stats.Rarity.Awesome: ValueDistribution.new(1., 5.),
	Stats.Rarity.Strange: ValueDistribution.new(1., 7.),
	Stats.Rarity.Mythical: ValueDistribution.new(1., 6.),
}

var RarityStrengthSummOfPositiveSubStatsDistribution := { # in percents / 100 -> (10% distributed by damage and speed)
	Stats.Rarity.Common: ValueDistribution.new(0.10, 0.10),
	Stats.Rarity.Uncommon: ValueDistribution.new(0.15, 0.15),
	Stats.Rarity.Rare: ValueDistribution.new(0.20, 0.20),
	Stats.Rarity.Awesome: ValueDistribution.new(0.30, 0.30),
	Stats.Rarity.Strange: ValueDistribution.new(0.45, 0.45),
	Stats.Rarity.Mythical: ValueDistribution.new(0.40, 0.40),
}

var RarityNumberOfNegativeSubStatsDistribution := {
	Stats.Rarity.Common: ValueDistribution.new(1., 2,),
	Stats.Rarity.Uncommon: ValueDistribution.new(0., 1.),
	Stats.Rarity.Rare: ValueDistribution.new(0, 0),
	Stats.Rarity.Awesome: ValueDistribution.new(0, 0),
	Stats.Rarity.Strange: ValueDistribution.new(1., 2.),
	Stats.Rarity.Mythical: ValueDistribution.new(0., 1.),
}

var RarityStrengthSummOfNegativeSubStatsDistribution := {
	Stats.Rarity.Common: ValueDistribution.new(0.10, 0.15),
	Stats.Rarity.Uncommon: ValueDistribution.new(0.02, 0.5),
	Stats.Rarity.Rare: ValueDistribution.new(0., 0.),
	Stats.Rarity.Awesome: ValueDistribution.new(0., 0.),
	Stats.Rarity.Strange: ValueDistribution.new(0.7, 0.15),
	Stats.Rarity.Mythical: ValueDistribution.new(0.5, 0.10),
}


class Attribute:
	var attribute_type : Stats.AttributeType
	var attribute_value: float
	
	
	func get_string() -> String:
		return Stats.get_attribute_string(attribute_type)
	func _init(type : Stats.AttributeType, value: float) -> void:
		attribute_type = type
		attribute_value = value
	
	func result_of_apply_base_distribution() -> float:
		return attribute_value * (0.95 + randf() * 0.10)
	
	func result_of_apply_rarity_base_distribution(rarity: Rarity) -> float:
		return attribute_value * Stats.RarityBaseDistributions[rarity].get_random_value()

class ItemAttributes:
	var item_rarity : Rarity
	var positive_additional_attributes : Array[Attribute] = []
	var negative_additional_attributes : Array[Attribute] = []
	
	func get_as_rich_text_header() -> String:
		return "[" + Stats.get_rich_rarity_string(item_rarity) + "]"
	
	func get_as_rich_text_bottom() -> String:
		var text = ""
		if len(positive_additional_attributes) > 0:
			text += "[color=green]Положительные дополнительные статы:[/color]\n"
		for attrib in positive_additional_attributes:
			text = text + "   {}: +{}%\n".format([attrib.get_string(), str(snapped(attrib.attribute_value * 100, 0.01))], "{}")
		if len(positive_additional_attributes) > 0:
			text += "\n"
		if len(negative_additional_attributes) > 0:
			text += "[color=red]Отрицательные дополнительные статы:[/color]\n"
		for attrib in negative_additional_attributes:
			text = text + "   {}: -{}%\n".format([attrib.get_string(), str(snapped(attrib.attribute_value * 100, 0.01))], "{}")
		if len(negative_additional_attributes) > 0:
			text += "\n"
		return text
	
	func get_as_text_header() -> String:
		return "[" + Stats.get_rarity_string(item_rarity) + "]"
	
	func get_as_text_bottom() -> String:
		var text = ""
		if len(positive_additional_attributes) > 0:
			text += "Положительные дополнительные статы:\n"
		for attrib in positive_additional_attributes:
			text = text + "   {}: +{}%\n".format([attrib.get_string(), str(snapped(attrib.attribute_value * 100, 0.01))], "{}")
		if len(positive_additional_attributes) > 0:
			text += "\n"
		if len(negative_additional_attributes) > 0:
			text += "Отрицательные дополнительные статы:\n"
		for attrib in negative_additional_attributes:
			text = text + "   {}: -{}%\n".format([attrib.get_string(), str(snapped(attrib.attribute_value * 100, 0.01))], "{}")
		if len(negative_additional_attributes) > 0:
			text += "\n"
		return text
	func as_rich_text() -> String:
		var stats_text = "\nСтаты Аксессуара:\n"
		return get_as_rich_text_header() + "\n" + stats_text + "\n" + get_as_rich_text_bottom()
	
	
	func as_text() -> String:
		var stats_text = "\nСтаты Аксессуара:\n"
		return get_as_text_header() + "\n" + stats_text + "\n" + get_as_text_bottom()
	func apply_rarity_to_base_attributes(): pass # base_atrib -> base_atrib
	func roll_base_attributes(): pass # base_atrib -> atrib
	func add_or_reroll_additional_attributes():
		positive_additional_attributes = []
		negative_additional_attributes = []
		var ad_at_positive_count : int = round(Stats.RarityNumberOfPositiveSubStatsDistribution[item_rarity].get_random_value())
		var ad_at_negative_count : int = round(Stats.RarityNumberOfNegativeSubStatsDistribution[item_rarity].get_random_value())
		var ad_at_positive_bank : float = Stats.RarityStrengthSummOfPositiveSubStatsDistribution[item_rarity].get_random_value()
		var ad_at_negative_bank : float = Stats.RarityStrengthSummOfNegativeSubStatsDistribution[item_rarity].get_random_value()
		var positive_values : Array[float] = []
		var summ : float = 0.
		for i in range(ad_at_positive_count):
			var val = randf()
			summ += val
			positive_values.append(val)
		for i in range(len(positive_values)):
			positive_values[i] = positive_values[i] / summ * ad_at_positive_bank / len(positive_values)
		for i in range(ad_at_positive_count):
			positive_additional_attributes.append(Attribute.new(Stats.get_random_attribute_type(), positive_values[i]))
		
		var negative_values : Array[float] = []
		summ = 0.
		for i in range(ad_at_negative_count):
			var val = randf()
			summ += val
			negative_values.append(val)
		for i in range(len(negative_values)):
			negative_values[i] = negative_values[i] / summ * ad_at_negative_bank / len(negative_values)
		for i in range(ad_at_negative_count):
			negative_additional_attributes.append(Attribute.new(Stats.get_random_attribute_type(), negative_values[i]))

class ValueDistribution:
	var attribute_value_distribution_min : float
	var attribute_value_distribution_max : float
	func _init(min_val: float, max_val: float) -> void:
		attribute_value_distribution_min = min_val
		attribute_value_distribution_max = max_val
	func get_random_value() -> float:
		return attribute_value_distribution_min + randf() * (attribute_value_distribution_max - attribute_value_distribution_min)

class WeaponAttributes extends ItemAttributes:
	var base_damage : Attribute
	var base_attack_speed : Attribute
	var base_crit_chance : Attribute
	var base_crit_damage : Attribute
	var base_attack_range: Attribute
	var base_lifesteal : Attribute
	var base_true_strike : Attribute
	var damage : Attribute
	var true_strike : Attribute
	var attack_speed : Attribute
	var crit_chance : Attribute
	var crit_damage : Attribute
	var attack_range: Attribute
	var lifesteal : Attribute
	
	func as_rich_text() -> String:
		var stats_text = "\nБазовые Статы Оружия:\n"
		stats_text += "   {}: {}\n".format([damage.get_string(), snapped(damage.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([attack_range.get_string(), snapped(attack_range.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([attack_speed.get_string(), snapped(attack_speed.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([crit_chance.get_string(), snapped(crit_chance.attribute_value * 100, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([crit_damage.get_string(), snapped(crit_damage.attribute_value * 100, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([lifesteal.get_string(), snapped(lifesteal.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([true_strike.get_string(), snapped(true_strike.attribute_value * 100, 0.01)], "{}")
		
		return get_as_rich_text_header() + "\n" + stats_text + "\n" + get_as_rich_text_bottom()
	
	
	func as_text() -> String:
		var stats_text = "\nБазовые Статы Оружия:\n"
		stats_text += "   {}: {}\n".format([damage.get_string(), snapped(damage.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([attack_range.get_string(), snapped(attack_range.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([attack_speed.get_string(), snapped(attack_speed.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([crit_chance.get_string(), snapped(crit_chance.attribute_value * 100, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([crit_damage.get_string(), snapped(crit_damage.attribute_value * 100, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([lifesteal.get_string(), snapped(lifesteal.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}%\n".format([true_strike.get_string(), snapped(true_strike.attribute_value * 100, 0.01)], "{}")
		
		return get_as_text_header() + "\n" + stats_text + "\n" + get_as_text_bottom()
	
	func _init(damage_val : float, attack_speed_val : float, crit_chance_val : float, crit_damage_val : float, attack_range_val : float, lifesteal_val : float, true_strike_val: float, rarity: Rarity) -> void:
		item_rarity = rarity
		base_damage = Attribute.new(AttributeType.damage, damage_val)
		base_attack_speed = Attribute.new(AttributeType.attack_speed, attack_speed_val)
		base_crit_chance = Attribute.new(AttributeType.crit_chance, crit_chance_val)
		base_crit_damage = Attribute.new(AttributeType.crit_damage, crit_damage_val)
		base_attack_range = Attribute.new(AttributeType.attack_range, attack_range_val)
		base_lifesteal = Attribute.new(AttributeType.lifesteal, lifesteal_val)
		base_true_strike = Attribute.new(AttributeType.true_strike, true_strike_val)
		true_strike = base_true_strike
		damage = base_damage
		lifesteal = base_lifesteal
		attack_speed = base_attack_speed
		crit_chance = base_crit_chance
		crit_damage = base_crit_damage
		attack_range = base_attack_range
	
	func roll_base_attributes():
		base_damage.attribute_value = base_damage.result_of_apply_base_distribution()
		base_attack_speed.attribute_value = base_attack_speed.result_of_apply_base_distribution()
		base_crit_chance.attribute_value = base_crit_chance.result_of_apply_base_distribution()
		base_crit_damage.attribute_value = base_crit_damage.result_of_apply_base_distribution()
		base_attack_range.attribute_value = base_attack_range.result_of_apply_base_distribution()
		base_lifesteal.attribute_value = base_lifesteal.result_of_apply_base_distribution()
		lifesteal = base_lifesteal
		damage = base_damage
		attack_speed = base_attack_speed
		crit_chance = base_crit_chance
		crit_damage = base_crit_damage
		attack_range = base_attack_range
	
	func apply_rarity_to_base_attributes():
		lifesteal.attribute_value = base_lifesteal.result_of_apply_rarity_base_distribution(item_rarity)
		damage.attribute_value = base_damage.result_of_apply_rarity_base_distribution(item_rarity)
		crit_damage.attribute_value = base_crit_damage.result_of_apply_rarity_base_distribution(item_rarity)
		crit_chance.attribute_value = base_crit_chance.result_of_apply_rarity_base_distribution(item_rarity)
		attack_speed.attribute_value = base_attack_speed.result_of_apply_rarity_base_distribution(item_rarity)
		attack_range.attribute_value = base_attack_range.result_of_apply_rarity_base_distribution(item_rarity)

class CharacterAttributes extends ItemAttributes:
	var base_health : Stats.Attribute
	var base_health_regeneration : Stats.Attribute
	var base_speed : Stats.Attribute
	var health : Stats.Attribute
	var health_regeneration : Stats.Attribute
	var speed : Stats.Attribute
	
	func _init() -> void:
		base_health = Stats.Attribute.new(Stats.AttributeType.health, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.health))
		base_health_regeneration = Stats.Attribute.new(Stats.AttributeType.health_regeneration, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.health_regeneration))
		base_speed = Stats.Attribute.new(Stats.AttributeType.speed, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.speed))
		health = base_health
		health_regeneration = base_health_regeneration
		speed = base_speed
	
	func as_rich_text() -> String:
		var stats_text = "\nБазовые Статы Персонажа:\n"
		stats_text += "   {}: {}\n".format([health.get_string(), snapped(health.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([health_regeneration.get_string(), snapped(health_regeneration.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([speed.get_string(), snapped(speed.attribute_value, 0.01)], "{}")
		return get_as_rich_text_header() + "\n" + stats_text + "\n" + get_as_rich_text_bottom()
	
	func as_text() -> String:
		var stats_text = "\nБазовые Статы Персонажа:\n"
		stats_text += "   {}: {}\n".format([health.get_string(), snapped(health.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([health_regeneration.get_string(), snapped(health_regeneration.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([speed.get_string(), snapped(speed.attribute_value, 0.01)], "{}")
		return get_as_text_header() + "\n" + stats_text + "\n" + get_as_text_bottom()
		
	func roll_base_attributes():
		base_health.attribute_value = base_health.result_of_apply_base_distribution()
		base_health_regeneration.attribute_value = base_health_regeneration.result_of_apply_base_distribution()
		base_speed.attribute_value = base_speed.result_of_apply_base_distribution()
	
	func apply_rarity_to_base_attributes():
		health.attribute_value = base_health.result_of_apply_rarity_base_distribution(item_rarity)
		health_regeneration.attribute_value = base_health_regeneration.result_of_apply_rarity_base_distribution(item_rarity)
		speed.attribute_value = base_speed.result_of_apply_rarity_base_distribution(item_rarity)

class ArmorAttributes extends ItemAttributes:
	var base_evasion : Stats.Attribute
	var base_mele_reduction : Stats.Attribute
	var base_projectile_reduction : Stats.Attribute
	var evasion : Stats.Attribute
	var mele_reduction : Stats.Attribute
	var projectile_reduction : Stats.Attribute
	func _init() -> void:
		base_evasion = Stats.Attribute.new(Stats.AttributeType.evasion, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.evasion))
		base_mele_reduction = Stats.Attribute.new(Stats.AttributeType.mele_damage_reduction, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.mele_damage_reduction))
		base_projectile_reduction = Stats.Attribute.new(Stats.AttributeType.projectile_damage_reduction, Stats.get_base_attribute_value_for_multiply(Stats.AttributeType.projectile_damage_reduction))
		evasion = base_evasion
		mele_reduction = base_mele_reduction
		projectile_reduction = base_projectile_reduction
	func as_rich_text() -> String:
		var stats_text = "\nБазовые Статы Брони:\n"
		stats_text += "   {}: {}\n".format([evasion.get_string(), snapped(evasion.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([mele_reduction.get_string(), snapped(mele_reduction.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([projectile_reduction.get_string(), snapped(projectile_reduction.attribute_value, 0.01)], "{}")
		return get_as_rich_text_header() + "\n" + stats_text + "\n" + get_as_rich_text_bottom()
	
	func as_text() -> String:
		var stats_text = "\nБазовые Статы Брони:\n"
		stats_text += "   {}: {}\n".format([evasion.get_string(), snapped(evasion.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([mele_reduction.get_string(), snapped(mele_reduction.attribute_value, 0.01)], "{}")
		stats_text += "   {}: {}\n".format([projectile_reduction.get_string(), snapped(projectile_reduction.attribute_value, 0.01)], "{}")
		return get_as_text_header() + "\n" + stats_text + "\n" + get_as_text_bottom()
	func roll_base_attributes():
		base_evasion.attribute_value = base_evasion.result_of_apply_base_distribution()
		base_mele_reduction.attribute_value = base_mele_reduction.result_of_apply_base_distribution()
		base_projectile_reduction.attribute_value = base_projectile_reduction.result_of_apply_base_distribution()
	
	func apply_rarity_to_base_attributes():
		evasion.attribute_value = base_evasion.result_of_apply_rarity_base_distribution(item_rarity)
		mele_reduction.attribute_value = base_mele_reduction.result_of_apply_rarity_base_distribution(item_rarity)
		projectile_reduction.attribute_value = base_projectile_reduction.result_of_apply_rarity_base_distribution(item_rarity)

func get_weapon_attributes_rarity(architype: Stats.WeaponArchiType, rarity: Rarity) -> WeaponAttributes:
	var attributes : WeaponAttributes = get_weapon_architype_base_attributes_with_random_rarity(architype)
	attributes.roll_base_attributes()
	attributes.item_rarity = rarity
	attributes.apply_rarity_to_base_attributes()
	return attributes

func get_weapon_architype_base_attributes_with_random_rarity(architype: WeaponArchiType) -> WeaponAttributes:
	match architype:
		WeaponArchiType.Axe: return WeaponAttributes.new(20, 1, 0.01, 2, 40, 0, 0, get_random_rarity())
		WeaponArchiType.Book: return WeaponAttributes.new(10, 1, 0.02, 2, 100, 0, 0, get_random_rarity())
		WeaponArchiType.Knife: return WeaponAttributes.new(8, 1, 0.03, 2, 30, 0, 0, get_random_rarity())
		WeaponArchiType.MagicOrb: return WeaponAttributes.new(8, 1, 0.01, 2, 200, 0, 0, get_random_rarity())
		WeaponArchiType.MagicStaff: return WeaponAttributes.new(20, 1, 0.01, 2, 300, 0, 0, get_random_rarity())
		WeaponArchiType.Rapier: return WeaponAttributes.new(20, 1, 0.01, 2, 40, 0, 0, get_random_rarity())
		WeaponArchiType.Spear: return WeaponAttributes.new(20, 1, 0.01, 2, 40, 0, 0, get_random_rarity())
		WeaponArchiType.Sword: return WeaponAttributes.new(20, 1, 0.01, 2, 40, 0, 0, get_random_rarity())
		WeaponArchiType.Fists: return WeaponAttributes.new(5, 1, 0.01, 2, 30, 0, 0, get_random_rarity())
		WeaponArchiType.HeavySword: return WeaponAttributes.new(5, 1, 0.01, 2, 30, 0, 0, get_random_rarity())
		WeaponArchiType.WarStaff: return WeaponAttributes.new(5, 1, 0.01, 2, 30, 0, 0, get_random_rarity())
	return WeaponAttributes.new(5, 1, 0.1, 2, 30, 0, 0, get_random_rarity())

class AttributeContainer:
	# character and weapon MUST exists
	var current_accs1 : ItemAttributes
	var current_accs2 : ItemAttributes
	var current_armor_head : ItemAttributes
	var current_armor_chest : ItemAttributes
	var current_armor_legs : ItemAttributes
	var current_weapon : WeaponAttributes
	var current_character : CharacterAttributes
	
	var result_attributes = {}
	
	func _ready(character_attribs, weapon_attribs) -> void:
		current_weapon = weapon_attribs
		current_character = character_attribs

	func get_attribute_or_null(attribute : Stats.AttributeType):
		if result_attributes.has(attribute):
			return result_attributes[attribute]
		else:
			return null
	func override_accessory1_attributes(item : ItemAttributes): # may be null
		current_accs1 = item
		force_update()
	func override_accessory2_attributes(item : ItemAttributes): # may be null
		current_accs2 = item
		force_update()
	func override_armor_head_attributes(item : ArmorAttributes): # may be null
		current_armor_head = item
		force_update()
	func override_armor_chest_attributes(item : ArmorAttributes): # may be null
		current_armor_chest = item
		force_update()
	func override_armor_legs_attributes(item : ArmorAttributes): # may be null
		current_armor_legs = item
		force_update()
	func override_character_attributes(item: CharacterAttributes):
		current_character = item
		force_update()
	func override_weapon_attributes(item: WeaponAttributes):
		current_weapon = item
		force_update()
	
	func get_as_rich_text() -> String:
		var text = "Итоговые Статы:\n"
		for k in result_attributes.keys():
			var val = result_attributes[k]
			text = text + "   {}: {}\n".format([Stats.get_attribute_string(k), str(snapped(val, 0.01))], "{}")
		text += "\n"
		text += current_character.as_rich_text()
		return text
	
	func get_final_stats() -> String:
		var text = "Итоговые Статы:\n"
		for k in result_attributes.keys():
			var val = result_attributes[k]
			text = text + "   {}: {}\n".format([Stats.get_attribute_string(k), str(snapped(val, 0.01))], "{}")
		return text
	
	func get_as_text() -> String:
		var text = "Итоговые Статы:\n"
		for k in result_attributes.keys():
			var val = result_attributes[k]
			text = text + "   {}: {}\n".format([Stats.get_attribute_string(k), str(snapped(val, 0.01))], "{}")
		text += "\n"
		text += current_character.as_text()
		return text
		
	func force_update():
		result_attributes = {}
		var attribute_modifyers = {} # summ of percents, then multiply on base
		var armor_mele_damage_reduction_summ = 0
		var armor_projectile_damage_reduction_summ = 0
		var armor_evasion_summ = 0
		if current_accs1:
			for stat : Stats.Attribute in current_accs1.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_accs1.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		if current_accs2:
			for stat : Stats.Attribute in current_accs2.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_accs2.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		if current_armor_head:
			armor_mele_damage_reduction_summ += current_armor_head.mele_reduction.attribute_value
			armor_projectile_damage_reduction_summ += current_armor_head.projectile_reduction.attribute_value
			armor_evasion_summ += current_armor_head.evasion.attribute_value
			for stat : Stats.Attribute in current_armor_head.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_armor_head.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		if current_armor_chest:
			armor_mele_damage_reduction_summ += current_armor_chest.mele_reduction.attribute_value
			armor_projectile_damage_reduction_summ += current_armor_chest.projectile_reduction.attribute_value
			armor_evasion_summ += current_armor_chest.evasion.attribute_value
			for stat : Stats.Attribute in current_armor_chest.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_armor_chest.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		if current_armor_legs:
			armor_mele_damage_reduction_summ += current_armor_legs.mele_reduction.attribute_value
			armor_projectile_damage_reduction_summ += current_armor_legs.projectile_reduction.attribute_value
			armor_evasion_summ += current_armor_legs.evasion.attribute_value
			for stat : Stats.Attribute in current_armor_legs.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_armor_legs.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		if current_character:
			for attrib in Stats.CharacterAttribute.keys(): if !attribute_modifyers.has(attrib): attribute_modifyers[attrib] = 0
			for stat : Stats.Attribute in current_character.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_character.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		else:
			push_warning("No character in attribute container!")
		if current_weapon:
			for attrib in Stats.WeaponAttribute.keys(): if !attribute_modifyers.has(attrib): attribute_modifyers[attrib] = 0
			for stat : Stats.Attribute in current_weapon.positive_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] += stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = stat.attribute_value
			for stat : Stats.Attribute in current_weapon.negative_additional_attributes:
				if attribute_modifyers.has(stat.attribute_type):
					attribute_modifyers[stat.attribute_type] -= stat.attribute_value
				else:
					attribute_modifyers[stat.attribute_type] = -stat.attribute_value
		else:
			push_warning("No weapon in attribute container!")
		for type in attribute_modifyers.keys():
			var multiplier = attribute_modifyers[type] + 1
			match type:
				AttributeType.health: result_attributes[type] = current_character.health.attribute_value * multiplier;
				AttributeType.health_regeneration: result_attributes[type] = current_character.health_regeneration.attribute_value * multiplier
				AttributeType.speed: result_attributes[type] = current_character.speed.attribute_value * multiplier
				AttributeType.damage: result_attributes[type] = current_weapon.damage.attribute_value * multiplier
				AttributeType.lifesteal:
					if current_weapon.lifesteal.attribute_value != 0.:
						result_attributes[type] = current_weapon.lifesteal.attribute_value * multiplier
					else:
						result_attributes[type] = (multiplier - 1)
				AttributeType.true_strike:
					if current_weapon.true_strike.attribute_value != 0.:
						result_attributes[type] = current_weapon.true_strike.attribute_value + (multiplier - 1)
					else:
						result_attributes[type] = (multiplier - 1)
				AttributeType.attack_speed: result_attributes[type] = current_weapon.attack_speed.attribute_value * multiplier
				AttributeType.crit_chance: result_attributes[type] = current_weapon.crit_chance.attribute_value + multiplier - 1
				AttributeType.crit_damage: result_attributes[type] = current_weapon.crit_damage.attribute_value + multiplier - 1
				AttributeType.attack_range: result_attributes[type] = current_weapon.attack_range.attribute_value * multiplier
				AttributeType.evasion:
					if armor_evasion_summ != 0:
						result_attributes[type] = armor_evasion_summ * multiplier
					else:
						result_attributes[type] = (multiplier - 1)
				AttributeType.mele_damage_reduction:
					if armor_mele_damage_reduction_summ != 0:
						result_attributes[type] = armor_mele_damage_reduction_summ * multiplier
					else:
						result_attributes[type] = (multiplier - 1)
				AttributeType.projectile_damage_reduction:
					if armor_projectile_damage_reduction_summ != 0:
						result_attributes[type] = armor_projectile_damage_reduction_summ * multiplier
					else:
						result_attributes[type] = (multiplier - 1)
				AttributeType.pierce: result_attributes[type] = Stats.get_base_attribute_value_for_multiply(type) * multiplier
				AttributeType.projectile_speed: result_attributes[type] = Stats.get_base_attribute_value_for_multiply(type) * multiplier
				#_: result_attributes[type] = Stats.get_base_attribute_value_for_multiply(type) * multiplier; push_warning("unregistred stat passes " + str(type))

func get_random_armor_attributes() -> ArmorAttributes:
	var armor_attributes : ArmorAttributes = ArmorAttributes.new()
	armor_attributes.roll_base_attributes()
	armor_attributes.item_rarity = get_random_rarity()
	armor_attributes.add_or_reroll_additional_attributes()
	return armor_attributes

func get_random_weapon_attributes_architype(type: Stats.WeaponArchiType) -> WeaponAttributes:
	var weapon_attributes : WeaponAttributes = get_weapon_architype_base_attributes_with_random_rarity(type)
	weapon_attributes.roll_base_attributes()
	weapon_attributes.add_or_reroll_additional_attributes()
	return weapon_attributes

func get_random_character_attributes() -> CharacterAttributes:
	var character_attributes : CharacterAttributes = CharacterAttributes.new()
	character_attributes.roll_base_attributes()
	character_attributes.item_rarity = get_random_rarity()
	character_attributes.add_or_reroll_additional_attributes()
	return character_attributes

func get_random_item_attributes() -> ItemAttributes:
	var item_attributes : ItemAttributes = ItemAttributes.new()
	item_attributes.item_rarity = get_random_rarity()
	item_attributes.add_or_reroll_additional_attributes()
	return item_attributes

enum WeaponArchiType{
	Axe,
	Book,
	Knife,
	MagicOrb,
	MagicStaff,
	Rapier,
	Spear,
	Sword,
	Fists,
	HeavySword,
	WarStaff,
}
