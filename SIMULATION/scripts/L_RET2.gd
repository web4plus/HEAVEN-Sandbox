extends Area2D

var RayCastList = ["Ray1", "Ray2", "Ray3", "Ray4", "Ray5", "Ray6", "Ray7", "Ray8"]


func _on_Timer_timeout():
	# Получить все пересечение в рецепторном поле
	var overlap_bodies = $CollisionPolygon2D.get_parent().get_overlapping_bodies()
	
	# Если кол-во пересечений больше нуля
	if len(overlap_bodies) > 0:
		# Переменная будет содержать 
		var ray_voting = []
		var winner_color = null
		# Получить данные от raycast что бы определить самый ближайший объект
		for ray in RayCastList:
			var ray_obj = get_node(ray)
			var ray_collider = ray_obj.get_collider()
			if ray_collider != null:
				ray_voting.append(ray_collider)
		
		var ray_voting_winner = null
		var ray_voting_winner_value = 0
		
		for overlap_elem in overlap_bodies:
			
			if ray_voting.count(overlap_elem) > ray_voting_winner_value:
				ray_voting_winner_value = ray_voting.count(overlap_elem)
				ray_voting_winner = overlap_elem
				winner_color = ray_voting_winner.self_color

		
		if winner_color != null:
			get_tree().root.get_node("MAIN/WORLD/CHARACTER/BODY").GET_BRIDGE("L_RET2", winner_color, 0.01)
			get_tree().root.get_node("MAIN/WORLD/EYES_VIEW/L2").color = winner_color


	else:
		#print("Остановка мониторинга")
		$Timer.stop()


func _on_L_RET2_body_entered(body):
	get_tree().root.get_node("MAIN").ADD_TO_CONSOLE("L2")
	$Timer.start()


func _on_L_RET2_body_exited(body):
	if len(get_overlapping_bodies()) == 0:
		get_tree().root.get_node("MAIN/WORLD/EYES_VIEW/L2").color = Color(00,00,00)




