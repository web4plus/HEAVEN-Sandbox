extends Area2D

func _on_Timer_timeout():
	if len($CollisionShape2D.get_parent().get_overlapping_bodies()) > 0:
		get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("FIB_L", null, 0.01)
	else:
		#print("Stop sensory processing")
		$Timer.stop()

func _on_FIB_L_body_entered(body):
	get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("FIB_L", null, 0.01)
	$Timer.start()
