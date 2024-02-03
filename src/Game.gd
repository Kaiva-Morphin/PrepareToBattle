extends Node



enum Team{
	player,
	enemy,
	other,
}

enum EntityState{
	idle,
	near,
	seek,
	attacking,
	casting,
	dead
}

@onready var manager = get_parent().get_node("Manager")
