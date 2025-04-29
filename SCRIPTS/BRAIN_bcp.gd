# BRAIN CONSTRUCTOR UI

extends Node2D

var mouse_position


# Called when the node enters the scene tree for the first time.
func _ready():
	
	#Add some options to the right-click pop up menu
	$BRAIN_POPMENU.clear()
	$BRAIN_POPMENU.add_item("SENSOR")
	$BRAIN_POPMENU.add_item("CGN")
	$BRAIN_POPMENU.add_item("INHIBITION")
	$BRAIN_POPMENU.add_item("EXHIBITION")
	$BRAIN_POPMENU.add_item("OUTPUT")
	$BRAIN_POPMENU.add_item("NGMC")
	$BRAIN_POPMENU.add_item("NSA")


#GUI Events processing
func _on_GraphEdit_gui_input(event):
	
	#Mouse right-click
	if event.is_action_pressed("mouse_right_click") == true:
		mouse_position = get_viewport().get_mouse_position()
		$BRAIN_POPMENU.popup(Rect2(mouse_position, Vector2(100, 10)))           # Spawn POP-UP: ADD new neurons


# POP-UP MENU: Adding neurons
func _on_BRAIN_POPMENU_id_pressed(id):
	var item_name = $BRAIN_POPMENU.get_item_text(id)

	if item_name == "SENSOR": 
		$GraphEdit.SPAWN_NODE("sensor", "")
	if item_name == "INHIBITION": 
		$GraphEdit.SPAWN_NODE("neuro", "")
	if item_name == "EXHIBITION": 
		$GraphEdit.SPAWN_NODE("exhibition", "")
	if item_name == "OUTPUT": 
		$GraphEdit.SPAWN_NODE("output", "")
	if item_name == "CGN": 
		$GraphEdit.SPAWN_NODE("cgn", "")
	if item_name == "NGMC": 
		$GraphEdit.SPAWN_NODE("ngmc", "")
	if item_name == "NSA": 
		$GraphEdit.SPAWN_NODE("nsa", "")

	

func _physics_process(_delta):
	# Monitor mouse position 
	$GraphEdit/MOUSE_COORD.text = str(get_node("GraphEdit").get_local_mouse_position())

