#GENERAL WORLD FUNCTIONS

extends Node2D

onready var GREEN_MOB = preload("res://SIMULATION/GREEN_circle.tscn")           # GREEN FOOD PRELOAD
onready var RED_MOB = preload("res://SIMULATION/RED_circle.tscn")               # RED FOOD PRELOAD

# INPUT PROCESSING
func _input(event):
	if event.is_action_pressed("ADD_MOB"):
		SPAWN_FOOD(GREEN_MOB, 450, 310, true)

	if event.is_action_pressed("ADD_POISON"):
		SPAWN_FOOD(RED_MOB, 450, 310, true)

# FOOD SPAWNING FUNCTION
func SPAWN_FOOD(food_type, x, y, move=false):
		var food_object = food_type.instance()
		food_object.moving = move
		get_node("FOOD").add_child(food_object)
		food_object.set_owner(self)
		food_object.position =  Vector2(x, y)
