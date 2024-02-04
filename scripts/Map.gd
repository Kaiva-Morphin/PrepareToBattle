extends ScrollContainer

#func _ready() -> void:
	#generate()
	#enable_layer(0)
#
#var layers_buttons = {}
#var button_childs = {}
#@onready var layers = $Map/Layers
#func generate() -> void:
	#for c in layers.get_children():
		#var layer_btns = {}
		#for b in c.get_children():
			#layer_btns[int(String(b.name))] = b
			#b.disabled = true
		#layers_buttons[int(String(c.name))] = layer_btns
	##button_childs
	#
	#for i in len(layers_buttons) - 1:
		#i = len(layers_buttons) - i - 1
		#var layer = layers_buttons[i]
		#var layer_size = len(layer)
		#var next_layer = layers_buttons[i - 1]
		#var next_layer_size = len(layer)
		#for next_node in next_layer.values():
			#for node in layer.values():
				#pass
			##button_childs[next_layer]
	#print(button_childs)
#
#func enable_layer(layer: int):
	#for v in layers_buttons[layer].values():
		#v.disabled = false
