extends Area2D


func _on_Timer_timeout():
	var overlap_bodies = $CollisionShape2D.get_parent().get_overlapping_bodies()
	if len(overlap_bodies) > 0:
		for body in overlap_bodies:
			get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("LS_big", body.filename, 0.01)
	else:
		$Timer.stop()


func _on_LS_big_body_entered(body):
	get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("LS_big", body.filename, body.mass/3)
	$Timer.start()

