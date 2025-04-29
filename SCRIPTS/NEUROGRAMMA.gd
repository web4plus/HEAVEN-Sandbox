# NUROGRAM Tool, monitor spikes for a group of neurons 
# TODO: add scallable field (more than 10 neurons in a row)

extends Panel

const main_color = Color(0,255,0)                                               # Spiked cells fill-up color
const empty_color = Color(0,0,0,0.1)                                            # No-spiked cells  fill-up color
const red_cursour_default_pos = Vector2(150,0)                                  # Default position of the red cursour 

var timeline_counter = 0.0                                                      # ...
var main_counter = 0                                                            # ...
var Connected_neurons = []                                                      # List of the links to connected neurons nodes
var Connected_neurons_names = {}                                                # Dictonary of connected neuron names and their links
var row_object = load("res://ROW_SAMPLE.tscn")                                  # Single row scene (added with every connected neuron)



# Called when the node enters the scene tree for the first time.
func _ready():
	$RED_CURSOUR/CURSOUR_LABEL.text = str(timeline_counter)                     # Set red cursor label as current timeline couner (0 by default)


# Function is connecting a new neuron to a neurogramm's REG
func REG_NEURON(node_name):
	var current_row = SET_NEURO_ROW(node_name)                                  # Add new row, remember in VAR
	var cell_values_array = current_row.row_cells_object_list                   # Get 57 cells of a new row
	Connected_neurons.append(current_row)                                       # ?
	Connected_neurons_names[node_name] = current_row                            # ?

# Function is adding a new row for a connected neuron 
func SET_NEURO_ROW(neuron_name):
	var new_row = row_object.instance()
	new_row.get_node("ROW_data/Background/Node_name_label").text = str(neuron_name)
	$Control/ScrollContainer/VBoxContainer.add_child(new_row)
	return new_row


func CALL_CELL(node_name):
	var node_row = Connected_neurons_names[node_name]                           # Giving an access to a row recorded after NAME. Senser if giving it's own 
	node_row.row_cells_object_list[main_counter-1].color = main_color           # Highlight given cell for a name, depending on Hz frame            
	
	
# Each timout will move the RED cursour +1 cell forward. 
# If neuron is connected via pop-up menu, it will send it calls each time it spiked and fill-up it's own cells of current Hz frame
func _on_Timer_timeout():
	for connected_neuron in Connected_neurons:
		if main_counter < 60:
			connected_neuron.row_cells_object_list[main_counter].color = empty_color

	main_counter += 1
	timeline_counter += $Timer.wait_time
	$RED_CURSOUR.set_position(Vector2(149 + 16*main_counter, 0))
	$RED_CURSOUR/CURSOUR_LABEL.text = str(timeline_counter)
	
	# If las cell was achieved, reset the cursor to the start, after which cells will be rewrited with every other Hz
	if main_counter == 61:
		main_counter = 0
		timeline_counter = 0.0
		$RED_CURSOUR.set_position(red_cursour_default_pos)



# Start spiking activity monitor
func _on_Button_pressed():
	$Timer.start()
	$NEUROGRAM_TOOLS_background/SpinBox.editable = false


# Stop & reset spiking activity monitor
func _on_Button2_pressed():
	$Timer.stop()
	main_counter = 0
	timeline_counter = 0.0
	
	$RED_CURSOUR.set_position(red_cursour_default_pos)
	$NEUROGRAM_TOOLS_background/SpinBox.editable = true
	$RED_CURSOUR/CURSOUR_LABEL.text = str(0)


# Change monitoring frequency (Hz) after it was changed in UI
func _on_SpinBox_value_changed(value):
	$Timer.wait_time = value

