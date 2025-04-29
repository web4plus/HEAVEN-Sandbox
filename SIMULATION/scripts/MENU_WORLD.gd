extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_btn_save_pressed():
	get_node("/root/MAIN").SAVE_WORLD()


func _on_btn_close_pressed():
	get_node("/root/MAIN").REMOVE_WORLD()
	pass # Replace with function body.

