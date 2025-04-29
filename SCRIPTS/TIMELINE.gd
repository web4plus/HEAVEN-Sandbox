extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
	_draw()
	update()
	$Label_end.text = str(get_parent().get_node("Timer").wait_time*60)
	


func _draw():
	
	var big_timeline_position = 1
	
	for big in range (1,8):
		big_timeline_position += 160
	
	var small_timeline_position = 1
	
	for small in range (1,62):
		small_timeline_position += 16

