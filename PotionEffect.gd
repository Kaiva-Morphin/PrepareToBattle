extends Area2D

var duration : float
var effect_treshold : float
var color : Color
var type : Potion.PotionType
func _ready():
	if color:
		$PointLight2D.color = color
	match type:
		Potion.PotionType.HealPotion:
			duration = 5
			effect_treshold = 0.2
		Potion.PotionType.LightingPotion:
			duration = 1.7
			effect_treshold = 0.5
		Potion.PotionType.PoisonPotion:
			duration = 5
			effect_treshold = 0.2
		Potion.PotionType.RagePotion:
			duration = 5
			effect_treshold = 0.2
		Potion.PotionType.SummonPotion:
			duration = 5
			effect_treshold = 0.2
		Potion.PotionType.TornadoPotion:
			duration = 3
			effect_treshold = 0.01
	$LifetimeTimer.start(duration)
	$EffectTimer.start(effect_treshold)
	_on_effect_timer_timeout()

var rage_speed_amount = 100.;
var rage_attack_speed_amount = 100.;
var heal_amount_percents = 3.;
var poison_amount_percents = 2.;
var lightning_damage_amount = 200.;

var under_effect = []

func _on_lifetime_timer_timeout() -> void:
	clear_effects()
	self.queue_free()

func clear_effects():
	pass

func _on_effect_timer_timeout() -> void:
	var tween = create_tween()
	tween.tween_property($PointLight2D, "energy", 3., effect_treshold * 0.8)
	tween.connect("finished", func(): $PointLight2D.energy = 1)
	tween.chain().tween_property($PointLight2D, "energy", 1, effect_treshold * 0.2)
	var bodies = get_overlapping_bodies()
	match type:
		Potion.PotionType.HealPotion:
			for body in bodies:
				if body is Entity:
					if body.team == Game.Team.player:
						var max_hp = body.attribute_container.get_attribute_or_null(Stats.AttributeType.health)
						var current_hp = body.current_hp
						if !max_hp: max_hp = 100
						body.take_heal(clamp(body.current_hp + max_hp * heal_amount_percents / 100., 0., max_hp))
		Potion.PotionType.LightingPotion:
			var entities = []
			for body in bodies:
				if body is Entity:
					entities.append(body)
			if len(entities) > 0:
				var e = entities.pick_random()
				var lightning_sprite = Sprite2D.new()
				lightning_sprite.texture = load("res://src/sprites/Potions/Lightning.png")
				lightning_sprite.offset = Vector2(4., -62.)
				lightning_sprite.modulate = Color(1., 1., 1., 0.5)
				Game.manager.add_child(lightning_sprite)
				lightning_sprite.global_position = e.global_position
				
				var lightning_tween = lightning_sprite.create_tween()
				lightning_tween.tween_property(lightning_sprite, "modulate", Color(1., 1., 1., 0.0), 0.2)
				lightning_tween.connect("finished", func(): lightning_sprite.queue_free())
				e.take_damage(lightning_damage_amount)
		Potion.PotionType.PoisonPotion:
			for body in bodies:
				if body is Entity:
					if body.team == Game.Team.enemy:
						body.take_damage(body.current_hp * poison_amount_percents / 100.)
		Potion.PotionType.RagePotion:
			pass
		Potion.PotionType.SummonPotion:
			pass
		Potion.PotionType.TornadoPotion:
			for body in bodies:
				if body is Entity:
					body.tornado = (self.global_position - body.global_position).normalized() * 50.
