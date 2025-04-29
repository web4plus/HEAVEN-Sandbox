extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var overlap_bodies = $CollisionShape2D.get_parent().get_overlapping_bodies()
	if len(overlap_bodies) > 0:
		for body in overlap_bodies:
			get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("RS_big", body.filename, 0.01)
			#print("++++++++++++++++++++++")
			#print("Отправка импульса")
	else:
		#print("----------------------")
		#print("Остановка мониторинга")
		$Timer.stop()
	#print("LS")
	pass # Replace with function body.



func _on_RS_big_body_entered(body):
	get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("RS_big", body.filename, body.mass/3)
	$Timer.start()
	pass # Replace with function body.
