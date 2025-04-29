extends RigidBody2D

onready var smell = preload("res://SIMULATION/POISON_smell.tscn")
var moving = false
var self_color = Color(255,00,00)


# Called when the node enters the scene tree for the first time.
func _ready():

	randomize()
	get_node("direction").wait_time = rand_range(0.0, 10.0)
	if moving == true:
		$direction.start()


func _on_Timer_timeout():
	var mob = smell.instance()
	mob.position = position 
	mob.set_collision_layer(1)
	mob.set_collision_layer(2)
	mob.set_collision_layer(3)

	mob.set_collision_mask(1)
	mob.set_collision_mask(2)
	mob.set_collision_mask(3)
	
	get_parent().add_child(mob)
	
	mob.set_owner(get_parent().get_parent()) 


func _on_direction_timeout():
	apply_impulse(Vector2(0,0), Vector2(rand_range(-100,100), rand_range(-100,100)))



func ACTION():
	get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").ENERGY(-2)
	queue_free()


func _on_RigidBody2D_mouse_entered():
	print('RIGHT CLICK')


func _on_RigidBody2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		print("CLICK")
