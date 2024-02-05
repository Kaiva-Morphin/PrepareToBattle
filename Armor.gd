class_name Armor
extends Item

@export var sprite_list : Array[Sprite2D] = []
@export var texture_variant_amount : int = 0
@export var texture_size : int = 16
@export var texture_column : int = 0

func randomize_texture():
	var i = randi_range(0, texture_variant_amount - 1)
	for sprite in sprite_list:
		if sprite.texture is AtlasTexture:
			sprite.texture.region = Rect2(Vector2(texture_size * texture_column, texture_size * i), Vector2(texture_size, texture_size))

func wear():
	pass
