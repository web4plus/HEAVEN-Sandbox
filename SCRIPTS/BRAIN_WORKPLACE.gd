extends GraphEdit

var GraphData = {}                                                              # DataField general dictonary
var BRIDGES_UP = {}                                                             # Dictonary of declarated bridges (Receptory field > Constructor's node)


# NEURON DIRECTORY MANAGER !!! 31012025
var sensor = load("res://NEURONS/SENSOR_adr+ v1.0.0/SENSOR_adr+.tscn")          # Sensory neuron (ADR2+)
var neuro = load("res://NEURONS/NEURON [+] v1.0.0/Neuron3_pn.tscn")             # Basic excitatory neuron (P+)
var exhibition = load("res://NEURONS/NEURON [-] v1.0.0/Neuron3_nega.tscn")      # Basic inhibitory neuron (N-)
var output = load("res://NEURONS/OUTPUT v1.0.0/OUTPUT.tscn")                    # Basic output neuron (Straightforward OUTPUT)
var amoto = load("res://NEURONS/AMOTO v1.0.0/AMOTO.tscn")                       # Alpha Motor neuron (AMOTO)
var asense = load("res://NEURONS/ASENSE v1.0.0/ASENSE.tscn")                    # Proprioceptor sensory neuron
var cgn = load("res://NEURONS/CGN+ v1.0.0/Neuron3_CGN.tscn")                    # CNG neuron
var ngmc = load("res://NEURONS/NGMC v1.0.0/NGMC.tscn")                          # NGMC neuron
var nsa = load("res://NEURONS/NSA v1.0.0/NSA.tscn")                             # NSA neuron

# TEST NEURONS
#var transporter = load("res://NEURONS/TRANSPORT_node.tscn")                     # Transporter neuron
#var resident = load("res://NEURONS/RESIDENT_node.tscn")                         # Resident neuron



# Called when the node enters the scene tree for the first time.
func _ready():

	$MOVE.offset = Vector2(400,-50)
	$JUMP.offset = Vector2(400, 50)
	$LEFT.offset = Vector2(400, 150)
	$RIGHT.offset = Vector2(400, 250)



# Function for cross-node connection establishment 
func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	print('Establishing connection from '+from+' to '+ to)
	connect_node(from, from_slot, to, to_slot)
	GraphData[from]["Connections"][from_slot][to] = {'AXON':0.01, 'SLOT_SENDR':from_slot, 'SLOT_RECVR':to_slot}
	get_node("/root/MAIN").MANAGE_NODE(from)


# Function for connection breaking (blocked, break with DISCONNECT_WITH_NEIGH_REMOVE)
func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):         # ???
	print('Connection break is blocked from '+from+' to '+ to)


# Function for connection breaking between 1 --> 2 conenction. (fix: slot?)
func DISCONNECT_WITH_NEIGH_REMOVE(sender_node_name, reciever_node_name, slot=null):
	var SENDER_connection_list = GraphData[sender_node_name]["Connections"][0]                      # connect to a neighbours list for 
	SENDER_connection_list.erase(reciever_node_name)                                                # remove 2 from 1 neighbours list
	disconnect_node(sender_node_name, 0, reciever_node_name, 0)
	


func SPAWN_NODE(node_type, node_title=null, node_position=null, bridge=false):
	
	var node
	
	# Choose neuron based on given type (fix: there is gotta be neuron's manager for local catalog) (fix)
	if node_type == 'sensor':
		node = sensor.instance()
	elif node_type == 'neuro':
		node = neuro.instance() 
	elif node_type == 'exhibition':
		node = exhibition.instance() 
	elif node_type == 'output':
		node = output.instance() 
	elif node_type == 'AMOTO':
		node = amoto.instance() 
	elif node_type == 'ASENSE':
		node = asense.instance() 
	elif node_type == 'cgn':
		node = cgn.instance() 
	elif node_type == 'ngmc':
		node = ngmc.instance() 
	elif node_type == 'nsa':
		node = nsa.instance() 
#	elif node_type == 'transporter':
#		node = transporter.instance() 
#	elif node_type == 'resident':
#		node = resident.instance() 
	# / Choose neuron based on given type

	# If node_title arg was defined, promote it as node title
	if node_title != null: 
		node.title = node_title
	
	# (fix) ?
	if bridge == true: 
		node.bridge_source = node_title
	
	# Spaw node into tree
	add_child(node)
	node.set_owner(get_parent())
	
	# Set node position, if it set by the args  
	if node_position != null: node.offset = node_position 
	
	# return node object
	return node










