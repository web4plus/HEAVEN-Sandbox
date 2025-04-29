extends Node2D

func _on_btn_save_pressed():
	get_node("/root/MAIN").SAVE_BRAIN()

func _on_btn_close_pressed():
	get_node("/root/MAIN").REMOVE_BRAIN()

func _on_Button_pressed():
	print(get_parent().get_node("GraphEdit").GraphData)

