extends Node2D

# Member variables for data retrieval and storage.
var DATA_reciever: Vector2 = Vector2(0, 0)

func _ready():
	# Initialize node and connect signals (if needed).
	pass

func _on_Button_pressed():
	"""
	Handle button press event.
	Retrieves value from text field, saves it to the graph data,
	and closes value change manager.
	"""

	# Get current value from text field.
	var VAL_value: float = float($Panel/VAL.text)
	
	# Save value to graph data at specified position.
	get_tree().root.get_node("MAIN/BRAIN/GraphEdit").GraphData[DATA_reciever[0]][DATA_reciever[1]] = VAL_value

	# Close value change manager.
	get_tree().root.get_node("MAIN").END_VALUE_CHANGER()
