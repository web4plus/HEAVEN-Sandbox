#######################################################################
### .///HEAVEN: Sandbox ########### web4plus.github.io ################
#######################################################################
# Project default scene's script
# Global variables
# Relay station for UI functions, managing the scenes, etc
#######################################################################


extends Node2D



########### settings
var current_project_catalog = null # SAVE folder for the project
########### /settings

########### scenes
var default_world = "res://SIMULATION/mian3.tscn"      # Default simulation scene
var default_brain = "res://BRAIN_bcp.tscn"             # Brain constructor scene 
var loading_world = null                               # Simulation scene variable container
var loading_brain = null                               # Brain constructor scene variable container
########### / scenes

########### roulette (two UI slots for scenes) 
var section_1 = null                                   # slot 1, directs to the scene on the left
var section_2 = null                                   # ^ slot 2, opposite
var selected_mode = "WORLD"                            # Standart scene in one-window mode (slot 1)
########### /roulette (two UI slots for scenes) 

########### Bridges icons
onready var grey_blue_bridge = load("res://IMG/SENS_OFF_ICO.png")
onready var grey_red_bridge = load("res://IMG/MOTO_OFF_ICO.png")
onready var blue_bridge = load("res://IMG/SENS_ICO.png")
onready var red_bridge = load("res://IMG/MOTO_ICO.png")
onready var purp_bridge = load("res://IMG/PROP_ICO.png")
onready var all_blue_bridge = load('res://IMG/SENS_ALL_ICO.png')
onready var all_red_bridge = load('res://IMG/MOTO_ALL_ICO.png')
onready var all_red_bridge_loaded = load('res://IMG/MOTO_ICO_ALL_LOADED.png')
########### /Bridges icons


# Called when the node enters the scene tree for the first time.
func _ready():
	$Panel/Mode_switcher.text = selected_mode            # Change mode switcher button text to a currently selected mode (Simulation/Brain constructor). Active when roulette in a double-side mode
	$Panel/TabContainer.current_tab = 1                  # Which teb will be selected by default (panel)
	$VALUE_CHANGER.hide()                                # Hide the UI element for changing a values within the neurons (Activation level etc)

	#ADD_TO_CONSOLE("Use this function for send the output to the inner terminal")


# Add message to a terminal (clear terminal by default is false, could require troubleshooting)
func ADD_TO_CONSOLE(mes, clear=false): 
	mes = str(mes) #message body 
	
	# clear terminal before adding, true or false
	if clear == true:
		$Panel/Main_console.set_text(mes)
	elif clear == false:
		$Panel/Main_console.insert_text_at_cursor(mes+"\n")
		


################## WORLD SCENE MANAGER FUNCTIONS (checking, loading, saving, etc)

# Function is checking is the WORLD scene is loaded into a current tree, boolean (true, false) 
func CHECK_WORLD(): 
	if get_node_or_null("WORLD") != null:
		return true
	else:
		return false

# Function is removing the world (if it does exist)
func REMOVE_WORLD(): 
	if CHECK_WORLD() == true:
		$WORLD.queue_free()
	else:
		print("Can't remove the world, if it does not exist")
		return false

 # Function is saving current simulation state as packedScene
func SAVE_WORLD():
	if CHECK_WORLD() == true:                         # If the world exist
		
		if current_project_catalog == null:           # but the project's foldes does not
			print('Project folder does not exist')
			return null
			
		# otherwise prepare packedScene for saving  / save
		var WORLD_pack = PackedScene.new()
		WORLD_pack.pack($WORLD)
		ResourceSaver.save("res://SAVE/"+current_project_catalog+"/WORLD.tscn", WORLD_pack)
		# / otherwise prepare packedScene for saving  

	else:
		print("ERROR: WORLD does not exist")

# Function is loading the scene into a tree, and place it into a roulette
func LOAD_WORLD(world): 
	print("Loading ", world)
	if CHECK_WORLD() == true:                          #If the world exist : message
		print("WORLD is already exist ")
		print('Please, close existing WORLD first')
	else:                                              # if it does not: load selected world
		loading_world = load(str(world))
		world = loading_world.instance()
		world.name = "WORLD"
		add_child(world)
		#print("INDEX " + str($WORLD.get_index()) )
		move_child($WORLD, 4)
		$Panel/Current_project_label
		SYNC_WORLD()
		get_node("SAVING_LOADING").hide() # Hide manager window

################## / WORLD SCENE MANAGER FUNCTIONS (checking, loading, saving, etc)



################## BRAIN SCENE MANAGER FUNCTIONS (checking, loading, saving, etc)

# Function is checking if the BRAIN scene is loaded into a current tree, boolean (true, false) 
func CHECK_BRAIN(): 
	if get_node_or_null("BRAIN") != null:
		print(get_node_or_null("BRAIN"))
		print("Brain constructor exist")
		return true
	else:
		print("Brain does not exist")	
		return false

# Function is removing the world (if it does exist) from the tree
func REMOVE_BRAIN():
	if CHECK_BRAIN() == true:
		$BRAIN.queue_free()
		print("BRAIN scene removed")
	else:
		print("BRAIN does not exist")


 # Function is saving current Brain state as packedScene
func SAVE_BRAIN():
	if CHECK_BRAIN() == true:                                                      # If the brain scene is loaded
		if current_project_catalog == null:                                        # If project folder does not exist not connected
			print('Project folder does not exist')
			return null
			
		# prepare packedScene for saving / save
		var BRAIN_pack = PackedScene.new()
		BRAIN_pack.pack($BRAIN)
		print("res://SAVE/"+current_project_catalog+"/BRAIN.tscn")
		ResourceSaver.save("res://SAVE/"+current_project_catalog+"/BRAIN.tscn", BRAIN_pack)
		# / prepare saving scene for saving
		
	else:
		print("BRAIN does not exist")


# Function is loading the brain constructor scene into a tree, and place it into a roulette
func LOAD_BRAIN(brain):
	if CHECK_BRAIN() == true: # if brain scene exist in tree
		
		# place in regarding to a selected mode (mode toggler) (arguable solution, why does it duplicated?)
		if $Panel/CheckButton.pressed == true:  #replacement if exist on load??
			SECTION($BRAIN,2)
		else: 
			SECTION($BRAIN,1)
		
	else: # if brain scene does not exist 
		print('> ', brain)
		loading_brain = load(brain)
		brain = loading_brain.instance()
		brain.name = "BRAIN"
		add_child(brain)
		move_child($BRAIN, 3)
		
		# Roulette placement 
		if $Panel/CheckButton.pressed == true: 
			SECTION($BRAIN,2)
		else: 
			SECTION($BRAIN,1)

################## / BRAIN SCENE MANAGER FUNCTIONS (checking, loading, saving, etc)





################## BRIDGES MANAGER FUNCTIONS (sync, etc)  >CURRENT 


# Function for setting up a single SENSORY bridge 
func SET_BRIDGE(item):
	ADD_TO_CONSOLE("Creating bridge for "+item.get_text(0))
	
	# First you gotta check if BRAIN scene is exist
	if CHECK_BRAIN() != true:
		ADD_TO_CONSOLE("To set up the bridge, you must create BRAIN project first!")
		return null
		
	# Then you gotta check if BRAIN scene is exist
	if CHECK_WORLD() != true:
		ADD_TO_CONSOLE("To set up the bridge, you must create WORLD project first!")
		return null
	
	# CHECK if the bridge record is exist (null by the default)
	var item_current_bridge = $WORLD/CHARACTER/BODY.BRIDGES_UP[item.get_text(0)]
	
	# If SENSORY BRIDGE record does not exist
	if item_current_bridge == null:
		var spawned_node = $BRAIN/GraphEdit.SPAWN_NODE('sensor',item.get_text(0), null,true)        # Spawn sensory nody
		$WORLD/CHARACTER/BODY.BRIDGES_UP[item.get_text(0)] = spawned_node.get_path()                # Set created node as a bridge reciever 
		
	# If SENSORY BRIDGE record exist
	elif item_current_bridge != null:
		ADD_TO_CONSOLE("Bridge is already exist")
		ADD_TO_CONSOLE(item.get_text(0))
		return null
		


# Function for setting up a single MOTO bridge 
func SET_MOTO_BRIDGE(item):
	ADD_TO_CONSOLE("Creating MOTO bridge for "+item.get_text(0))
	
	# First you gotta check if BRAIN scene is exist
	if CHECK_BRAIN() != true:
		ADD_TO_CONSOLE("To set, You must create BRAIN project first!")
		return null
		
	# Then you gotta check if BRAIN scene is exist
	if CHECK_WORLD() != true:
		ADD_TO_CONSOLE("To set, You must create WORLD project first!")
		return null
	
	# CHECK if the bridge record is exist (null by the default). 
	# For the MOTO addidtion subelements check required
	var item_current_bridge = $WORLD/CHARACTER/BODY.BRIDGES_DOWN[item.get_text(0)]
	
	
	# SPAWN the node of related type (AMOTO/ASENSE), if it does not occupied yet in bridges records
	for FEV_element in item_current_bridge:                                     # Walk trough each subelement of the MOTOR bridge
		if item_current_bridge[FEV_element]["Node"] == null:
			var spawned_node = $BRAIN/GraphEdit.SPAWN_NODE(item_current_bridge[FEV_element]["Type"],item.get_text(0), null,true)
			$WORLD/CHARACTER/BODY.BRIDGES_DOWN[item.get_text(0)][FEV_element]["Node"] = spawned_node.get_path()
			
		elif item_current_bridge[FEV_element]["Node"]  != null:
			ADD_TO_CONSOLE("Moto bridge alreay exist")
			return null
			

# Function removing bridge from BRIDGES records in Datafield
func REMOVE_BRIDGE(item):

	if CHECK_BRAIN() != true:
		ADD_TO_CONSOLE("To remove, You must create BRAIN project first!")
		return null
	if CHECK_WORLD() != true:
		ADD_TO_CONSOLE("To remove, You must create WORLD project first!")
		return null

	# GET bridge record from the DataField, null by default (non existing bridge)
	var item_current_bridge = $WORLD/CHARACTER/BODY.BRIDGES_UP[item.get_text(0)]
	
	# If the record was found
	if item_current_bridge != null:
				
		if get_node_or_null(item_current_bridge) != null:
			get_node(item_current_bridge)._on_GraphNode_close_request()
		else:
			print('Node has not been found')
			
		$WORLD/CHARACTER/BODY.BRIDGES_UP[item.get_text(0)] = null               # Set up bridges record to null # 250125 moved to bottom of the function
		print('The bridge record has been removed')
		
	elif item_current_bridge == null:
		print("The bridge does not exist yet")




# Function for the bridges synchronization:
# 1 Getting bridges state from the body in the WORLD simulation
# 2 Reloading managers
func SYNC_WORLD():  # +
	
	if CHECK_WORLD() == true:
		
		var sense_bridges = $WORLD/CHARACTER/BODY.BRIDGES_UP                    # Receive bridges tree for sensory system
		var moto_bridges = $WORLD/CHARACTER/BODY.BRIDGES_DOWN                   # Receive bridges tree for motor system
		
		var sense_bridges_list = []
		var moto_bridges_list = []

		# Fill up the sensory bridges list
		for receptor_id in sense_bridges:
			print("Receptory functions "+receptor_id)
			sense_bridges_list.append(receptor_id) 

		# Fill up the motor bridges list
		for moto_id in moto_bridges: # LEFT, RIGHT, etc
			print("Motor functions  "+moto_id)
			moto_bridges_list.append(moto_id) 
		
		# Clear the bridges manager (sensory) and call SENS bridges sync function
		$Panel/TabContainer/BRIDGES/Bridges_tabcontainer/SENSORY/WorldTree.clear()
		ADD_TO_WORLD_BRIDGE_MANAGER(sense_bridges_list, sense_bridges)
		
		# Clear the bridges manager (sensory) and call MOTO bridges sync function
		$Panel/TabContainer/BRIDGES/Bridges_tabcontainer/MOTOR/MotoTree.clear()
		ADD_TO_MOTO_BRIDGE_MANAGER(moto_bridges_list, moto_bridges)

		
	else:
		ADD_TO_CONSOLE("World Sync error")
		ADD_TO_CONSOLE("World is not found")
	





# This function is fills up the SENSORY bridges manager with a given list 
func ADD_TO_WORLD_BRIDGE_MANAGER(bridges_list, bridges_dic):
	
	#SENSORY MANAGER tree scene link, where bridges will be placed
	var World_tree = $Panel/TabContainer/BRIDGES/Bridges_tabcontainer/SENSORY/WorldTree  

	var World_tree_root = World_tree.create_item()                              # create the root of bridges list
	 
	World_tree_root.set_text(0,"SENSORY_BRIDGES")                               # set root's text #SENSE
	World_tree_root.add_button(0,all_blue_bridge)                               # add "ALL" button (connect all bridges at once)
	
	# walk trough the list of given sensory bridges
	for receptor_name in bridges_list:
		var bridge_item = World_tree.create_item(World_tree_root)               # set bridge element in root
		bridge_item.set_text(0, receptor_name)                                  # set text to a element (sens bridge name)
		var bridge_item_node = World_tree.create_item(bridge_item)              # 

		if bridges_dic[receptor_name] != null: 
			print('')
			bridge_item_node.set_text(0,bridges_dic[receptor_name])
			bridge_item.add_button(0,blue_bridge) 
		else:
			bridge_item_node.set_text(0,"NOT CONNECTED")
			bridge_item.add_button(0,grey_blue_bridge) 





# This function is fills up the MOTO bridges manager with a given list of bridges
func ADD_TO_MOTO_BRIDGE_MANAGER(bridges_list, bridges_dic):
	
	# MOTO MANAGER tree scene link, where bridges will be placed
	var Moto_tree = $Panel/TabContainer/BRIDGES/Bridges_tabcontainer/MOTOR/MotoTree  
	
	var Moto_tree_root = Moto_tree.create_item()                                # create the root of bridges list
	
	Moto_tree_root.set_text(0,"MOTO_BRIDGES")                                   # set root's text #SENSE
	Moto_tree_root.add_button(0,all_red_bridge)                                 # add "ALL" button (connect all bridges at once)
	
	# walk trough the list of given sensory bridges
	for FEV_name in bridges_list: # LEFT, RIGHT, etc
		var bridge_item = Moto_tree.create_item(Moto_tree_root)                 # set bridge element in root
		bridge_item.set_text(0, FEV_name)                                       # set text to a element (moto bridge name) (Ex. Adam has LEFT, RIGHT, EAT)
		bridge_item.add_button(0,all_red_bridge_loaded)                         # add connection button. Connect's both MOTO and PROP bridges. RED by default                           
	
	
		# Add MOTO and PROP bridges under the bridge name
		for FEV_subnode in bridges_dic[FEV_name]:                               # Walk troght all of the subelements of the current bridge (MOTO & PROP usually)
			var Subelement_data                                                 
			var Subelement_button
			
			if bridges_dic[FEV_name][FEV_subnode]["Node"] == null:              # If bridge record is empty in REG (General datafield) 
				Subelement_data = 'NOT CONEECTED'
				Subelement_button = grey_red_bridge
				bridge_item.erase_button(0,0)                                   # Remove root MOTO  bridge button if at least one subelement is not connected
				bridge_item.add_button(0,grey_red_bridge)                       # Set grey button for a MOTO bridge 

			else:                                                               # If bridge record exist
				Subelement_data = bridges_dic[FEV_name][FEV_subnode]["Node"]
				print('EXIST, data:')
				
				#Choose the icon for a subelement in a MOTO bridge depending on it's type 
				if bridges_dic[FEV_name][FEV_subnode]['Type'] == 'AMOTO':
					Subelement_button = red_bridge                              # AMOTO (Alpha moto neuron), RED
				elif bridges_dic[FEV_name][FEV_subnode]['Type'] == 'ASENSE':
					Subelement_button = purp_bridge                             # ASENSE (Propricetor), PURPLE
				
			var FEV_subconstruction = Moto_tree.create_item(bridge_item)        # Add MOTO subelement 
			FEV_subconstruction.set_text(0, FEV_subnode)                        # Set MOTO subelement text
			FEV_subconstruction.add_button(0, Subelement_button)                # Add button (red / purple)
			
			var FEV_subconstruction_data = Moto_tree.create_item(FEV_subconstruction) #Add MOTO subelemnt's connection status / NODE path
			FEV_subconstruction_data.set_text(0, Subelement_data)               #Set text ^
			

# SENSORY bridges buttons. Processing is depend on type of the button
func _on_WorldTree_button_pressed(item, column, id): 
	
	 # Get pressed button object 
	var pressed_button = item.get_button(0, id)                                

	# GREY BUTTON (bridge does not exist)
	if pressed_button == grey_blue_bridge:
		SET_BRIDGE(item)
		SYNC_WORLD()
	
	# BLUE BUTTON (bridge exist) broken
	elif pressed_button == blue_bridge:
		print("blue_bridge (REMOVE)")
		#REMOVE_BRIDGE(item) (fix)
		#SYNC_WORLD()        (^)  
	
	# ALL BUTTON (Connect all bridges at once)
	elif pressed_button == all_blue_bridge:
		ADD_TO_CONSOLE("Creating bridges for all receptors")
		# (fix)


# MOTO bridges buttons. Processing is depend on type of the button
func _on_MotoTree_button_pressed(item, column, id):
	
	 # Get pressed button object 
	var pressed_button = item.get_button(0, id)

	# GREY button (bridge does not exist)
	if pressed_button == grey_red_bridge: 
		SET_MOTO_BRIDGE(item)
		SYNC_WORLD()
	
	# RED button (bridge exist)
	elif pressed_button == red_bridge: 
		print('Removing functionality is not exist for motor bridges') #(fix)
		#REMOVE_BRIDGE(item)
		#SYNC_WORLD()
	
	# ALL BUTTON (Connect all bridges at once)
	elif pressed_button == all_blue_bridge: 
		ADD_TO_CONSOLE("Creating bridges for all receptors")
		
	#elif purple (fix) 250125
	
################## / BRIDGES MANAGER FUNCTIONS


####################### NEURONS MANAGER

# Function is open node MANAGER for a specific node. 
# If switch == true, switch tab to manager.

func MANAGE_NODE(node_name, switch_to = true):
	
	if switch_to == true:
		$Panel/TabContainer.current_tab = 2 # Switch to manager
	
	# Set the name of selected node as title
	$Panel/TabContainer/NEURONS/ID_LineEdit.text = node_name
	
	#Clear tree for further operations (re-fill the tree)
	$Panel/TabContainer/NEURONS/Tree.clear()
	
	# Set up tree root 
	var tree_root = $Panel/TabContainer/NEURONS/Tree.create_item() 
	
	# Set up tree root name (selected node)
	tree_root.set_text(0,node_name) 
	
	# Get  a list of connections for selected node
	var GraphData_source = get_node_or_null("BRAIN/GraphEdit")
	var NODE_connection_list = {}
	
	if GraphData_source != null:
		NODE_connection_list = GraphData_source.GraphData[node_name]["Connections"]
		print(NODE_connection_list)
	else:
		print("Error: can't get a list of connected nodes "+ node_name)
		return 0
		
	# Fill up a tree manager 
	if len(NODE_connection_list):                                                                   # IF connected nodes list == true it have a lenght
		
		for port in NODE_connection_list:                                                           # Walk trough the ports, which have connections
			for conn_link in NODE_connection_list[port]:                                            # Walk trough all connected nodes withen the port
				var conn_record = $Panel/TabContainer/NEURONS/Tree.create_item(tree_root)           # Add record about connection to a manager
				conn_record.set_text(0,conn_link)                                                   # Set up a text for the current record
				conn_record.add_button(0,load('res://IMG/CLOSE_ICO.png'))                           # Add a button for connection breaking
			
	# If there is no connections
	elif len(NODE_connection_list) == 0:                     
		$Panel/TabContainer/NEURONS/Tree.create_item(tree_root).set_text(0,"Connections is empty")


# Buttons processing for a NEURONS manager (Only X at the moment)
func _on_Tree_button_pressed(item, column, id):
	var sender_node_name = $Panel/TabContainer/NEURONS/Tree.get_root().get_text(0)                    # Get sender node
	var reciever_node_name = item.get_text(0)                                                       # Get sender node name (Record on the left from the button)
	var GraphData_source = get_node_or_null("BRAIN/GraphEdit")                                      # Get a link directly to Brain Constructor
	
	# Remove a connection from DataField
	if GraphData_source != null:                                                                    # If Brain Constructor Scene has been found
		GraphData_source.DISCONNECT_WITH_NEIGH_REMOVE(sender_node_name, reciever_node_name)         # Advanced disconnect function, removing the record from DataField + changing the state of neuron (it's neighbours list)
		MANAGE_NODE(sender_node_name)                                                               # Reload Manager
	else:
		print("Error while trying to remove a connection from FataField")
		return 0
		
####################### /NEURONS MANAGER



################## / UI ELEMENTS AND FUNCTIONS (Roulette, saving/loading manager etc)
# ROULETTE is dual-sided UI mode, that allows to run both (simulation and constructor)

# Function is placing the selected scene into 1/2 roulette section
func SECTION(node_object, section_n): 

	# settings
	var current_section = null
	var pos = null
	var total_width = Vector2(0,1500) 
	# / settings

	# section selector 
	if section_n == 1: 
		current_section = section_1 #Link to global section variable
		pos = Vector2(0,0)
	elif section_n == 2: 
		current_section = section_2 #Link to global section variable
		pos = Vector2(1470,0)
	else:
		print('Selected section not found') #Sections other than left/right is currently not supported
		return 0
	# / section selector 
		
	# If selected (new) scene is deffirent from currently presented within selected roulette section
	if node_object != current_section: 
		if current_section != null: 
			# ! If world was unexpectedly closed = error (fix)
			current_section.position = total_width
			
		node_object.position = pos                                              # Move selected scene into a position (POS)
		node_object.show()                                                      # Show scene 
		
		if section_n == 1: 
			section_1 = node_object                                             # Set global section var contain the selected scene 
		elif section_n == 2: 
			section_2 = node_object                                             # Set global section var contain the selected scene 


# Function expand ROULETTE AREA into a double-sided mode
func EXPAND_AREA(): 
	OS.window_size = Vector2(2595,910)                                          # change wondow size (expand)
	$Panel/Mode_switcher.disabled = true                                        # decativate mode switcher botton
	$Panel/CheckButton.pressed = true                                           # Switch toggler into ON state

	SECTION($START_PAGE_WORLD, 1)                                               # Show WORLD loading scene
	SECTION($START_PAGE_BRAIN, 2)                                               # Show BRAIN loading scene 


	if CHECK_WORLD() == true : SECTION($WORLD,1)                                # If WORLD exist - put it into section 1 
	if CHECK_BRAIN() == true: SECTION($BRAIN,2)                                 # If BRAIN exist - put in into section 2
		
		
		
# Function convert ROULETTE into a single-sided mode
func DECREASE_AREA(): 
	OS.window_size = Vector2(1473,910)
	
	$Panel/Mode_switcher.disabled = false 
	$Panel/CheckButton.pressed = false 
	
	SECTION($START_PAGE_WORLD,1)
	
	if CHECK_WORLD() == true : 
		SECTION($WORLD,1)
	else:
		if CHECK_BRAIN() == true:
			SECTION($BRAIN,1)
			
	section_2 = null # Setting up section 2 global variable to null (otherwise there is a bug)
	


# Function open value changer window, accepting value and reciever node
func START_VALUE_CHANGER(value, param_key): 
	$VALUE_CHANGER.position = Vector2(500,500)
	$VALUE_CHANGER/Panel/VAL.text = str(value)
	$VALUE_CHANGER.DATA_reciever = param_key 
	$VALUE_CHANGER.show()


# Function is hiding value changer window
func END_VALUE_CHANGER():
	$VALUE_CHANGER.hide()


#Function is enables SAVING / LOADING manager 
func START_MANAGER():
	get_tree().paused = true # Stop the global time of the software (pause the program unless other is defined in elements) 

	# Manager settings that depends on state of the WORLD/BRAIN nodes
	if CHECK_WORLD() == true: 
		$SAVING_LOADING/World_checkbutton.disabled = false 
		$SAVING_LOADING/World_label_manager.text = "res://link-to-world" 
	else:
		$SAVING_LOADING/World_checkbutton.disabled = true 
		$SAVING_LOADING/World_label_manager.text = "World is not created yet"
		
		
	if CHECK_BRAIN() == true: 
		$SAVING_LOADING/Brain_checkbutton.disabled = false 
		$SAVING_LOADING/Brain_label_manager.text = "res://link-to-brain" 
	else:
		$SAVING_LOADING/Brain_checkbutton.disabled = true
		$SAVING_LOADING/Brain_label_manager.text = "Brain is not created yet"
	# / Manager settings that depends on state of the WORLD/BRAIN nodes
	
	get_node("SAVING_LOADING").show() # Show manager
################## / UI ELEMENTS AND FUNCTIONS (Roulette, saving/loading manager etc)





############ UI buttons proccessing

func _on_SYNC_WORLD_pressed(): 
	print("WORLD SYNC")
	SYNC_WORLD()


func _on_PLAY_pressed():
	Engine.time_scale = 1
	get_tree().paused = false


func _on_PAUSE_pressed():
	get_tree().paused = true


# Switch SCENE (world > brain > world > ...)  for a single-sided mode
func _on_Mode_switcher_pressed():
	if selected_mode == "BRAIN":                                                # If BRAIN was selected
		get_node("Panel/Mode_switcher").text = "> BRAIN"                        # Change  switcher button text to opposite
		SECTION($START_PAGE_WORLD, 1)                                           # move WORLD loading scene to a section 1
		if CHECK_WORLD() == true : SECTION($WORLD, 1)                           # If the world is loaded , move it to a section 1
		selected_mode = "WORLD"                                                 # change global variable for selected mode 
		
	elif selected_mode == "WORLD":                                              # If WORLD was selected
		get_node("Panel/Mode_switcher").text = "> WORLD"                        # Change  switcher button text to opposite
		SECTION($START_PAGE_BRAIN, 1)                                           # move BRAIN loading scene to a section 1
		if CHECK_BRAIN() == true : SECTION($BRAIN, 1)                           # If the brain is loaded,  move it to a section 1
		selected_mode = "BRAIN"                                                 # change global variable for selected mode 


# ROULETTE mode switcher dual-sided > single-sided > dual...
func _on_CheckButton_pressed():                                                
	if $Panel/CheckButton.pressed == true: 
		EXPAND_AREA()
	if $Panel/CheckButton.pressed == false:
		DECREASE_AREA()

# SAVING/LOADING manager button pressed
func _on_MANAGER_pressed():
	START_MANAGER()
	
	
# WORLD defualt loading scene (New project button)
func _on_New_project_world_pressed():
	LOAD_WORLD(default_world)
	
# WORLD defualt loading scene (Load project button)
func _on_Load_world_pressed():
	$START_PAGE_WORLD/Load_world/FileDialog.popup()

# WORLD defualt loading scene (File manager processing: file selected)
func _on_FileDialog_file_selected(path): 
	LOAD_WORLD(path)

# BRAIN defualt loading scene (New project button)
func _on_New_project_brain_pressed():
	print(default_brain)
	print("^ ")
	LOAD_BRAIN(default_brain)

# BRAIN defualt loading scene (Load project button)
func _on_Load_brain_pressed(): 
	$START_PAGE_BRAIN/Load_brain/FileDialog_brain.popup()


# BRAIN defualt loading scene (File manager processing: file selected)
func _on_FileDialog_brain_file_selected(path):
	LOAD_BRAIN(path)

############ / UI buttons proccessing



############ Test buttons

#Min body energy
func _on_TEST_button3_pressed():
	get_node("WORLD/CHARACTER/BODY").energy_value = -19

#Max body energy
func _on_TEST_button4_pressed():
	get_node("WORLD/CHARACTER/BODY").energy_value = 19
	
func _on_FORWARD_pressed():
	#Engine.time_scale = 5
	pass # Replace with function body.

func _on_BACKWARD_pressed():
	Engine.time_scale = 0.1


# Switch to a full-screen-mode
func _on_Button_pressed():
	if OS.window_fullscreen == true:
		OS.window_fullscreen = false
	elif OS.window_fullscreen == false:
		OS.window_fullscreen = true

############ / Test buttons
