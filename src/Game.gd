extends Node

'''
Вместилище глобальных переменных
'''

# id -> data ({})
# data <- {"wirangs"}




var inventory = [
	{}
]


var current_state = GameState.prepare

enum GameState{
	prepare,
	inbattle
}

enum Team{
	player,
	enemy,
	other,
}

enum EntityState{
	idle,
	near,
	seek,
	dead,
}

@onready var manager = get_parent().get_node("Manager")
