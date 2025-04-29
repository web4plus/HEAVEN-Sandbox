#NEUROGRAMM component: single neuron row

extends HBoxContainer

var row_neuron_label = null
var row_cells_object_list = []
var start_position = 101

# Called when the node enters the scene tree for the first time.
func _ready():

	# Generate a single row of cells
	for cell in range(0,60):
		var CELL_RECT = ColorRect.new()

		CELL_RECT.set_position(Vector2(start_position,1))
		CELL_RECT.color = Color(5,5,5,0.1)
		CELL_RECT.set_size(Vector2(13,13))

		$ROW_data.add_child(CELL_RECT)
		
		CELL_RECT.show()
		
		start_position += 16
		row_cells_object_list.append(CELL_RECT)
