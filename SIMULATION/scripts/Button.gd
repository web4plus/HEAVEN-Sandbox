extends StaticBody2D

var self_color = Color(255,00,00)

func ADD_MOB():
	get_parent().SPAWN_FOOD(get_parent().GREEN_MOB, 1000, 350, true)

#? ^
func ACTION():
	ADD_MOB()
