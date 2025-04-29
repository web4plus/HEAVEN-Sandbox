extends RigidBody2D

onready var smell = preload("res://SIMULATION/FOOD_smell.tscn")
var moving = false
var self_color = Color(00,255,00)


# Variables for drag & drop 
var is_dragging = false 
var mouse_offset = Vector2() 


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	get_node("direction").wait_time = rand_range(0.0, 10.0)
	if moving == true:
		$direction.start()


func _input(event):
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT: 
			if event.pressed: 
				if get_global_transform().xform(Vector2.ZERO).distance_to(get_global_mouse_position()) < 10: 
					is_dragging = true 
					print('DRAGGING TRUE') 
					mouse_offset = global_position - get_global_mouse_position() 
				else: 
					is_dragging = false 


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
	#print(rand_range(0,1))
	apply_impulse(Vector2(0,0), Vector2(rand_range(-100,100), rand_range(-100,100)))



func ACTION():
	get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").ENERGY(2)
	queue_free()


func _on_RigidBody2D_mouse_entered():
	print('RIGHT CLICK')


func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()+mouse_offset
		mode = RigidBody2D.MODE_KINEMATIC
	else:
		mode= RigidBody2D.MODE_RIGID
