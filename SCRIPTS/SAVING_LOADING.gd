# PROJECT SAVING/LOADING MANAGER SCRIPT 
extends Node2D

var saves
onready var MAIN = get_node("/root/MAIN")


# Called when the node enters the scene tree for the first time.
func _ready():
	REFRESH_SAVENAME()                                                         
	REFRESH_CATALOG()


# Function for saving the WORLD as packedScene (clone from MAIN.gd, fix?)
func SAVE_WORLD(): 
	if MAIN.CHECK_WORLD() == true:
		
		if MAIN.current_project_catalog == null:
			print("Can't find project directory global record (MAIN.gd)")
			return null #Break
		else:
			print('Project folder is found')
			
		var WORLD_pack = PackedScene.new()                                                          #Pack current scene
		WORLD_pack.pack(MAIN.get_node("WORLD"))                                                     # ...
		ResourceSaver.save("res://SAVE/"+MAIN.current_project_catalog+"/WORLD.tscn", WORLD_pack)    #Save packedScene
		
	else:
		print("WORLD does not exist")
		return null



# Function for saving the BRAIN as packedScene (clone from MAIN.gd, fix?)
func SAVE_BRAIN(): 
	if MAIN.CHECK_BRAIN() == true: 
		
		var BRAIN_pack = PackedScene.new()                                                          # Pack current scene 
		BRAIN_pack.pack(MAIN.get_node("BRAIN"))                                                     # ...
		ResourceSaver.save("res://SAVE/"+MAIN.current_project_catalog+"/BRAIN.tscn", BRAIN_pack)    #Save packedScene
		
	else:
		print("BRAIN does not exist")
		return null



# Function for opening the project
func OPEN_PROJECT(ite): 
	# Defines path for savings (fix: link to singleton)
	var catalog_link = "res://SAVE/"
	# Get a text from given arg
	var cat_id = ite.get_text(0)
	# Defines a complete path to saved project
	catalog_link = catalog_link + cat_id
	
	# If selected project is already opened, block loader
	if MAIN.current_project_catalog == cat_id: 
		$WindowDialog.window_title = "Information"
		$WindowDialog/RichTextLabel2.text = "Project already loaded"
		$WindowDialog.popup()
		return null
	
	# If it's not, let's continue loading
	# Loading configuraion file form project's catalog
	var config_file_loaded = ConfigFile.new()
	config_file_loaded.load(catalog_link+"/Settings.conf")
	var section_list = config_file_loaded.get_sections() 


	if 'WORLD' in section_list:
		MAIN.LOAD_WORLD(catalog_link+"/WORLD.tscn") # Loading world scene into roulette
		
		# Loading data from the CONFIG about connected sensory bridges
		var loading_world_BRIDGES_UP = config_file_loaded.get_value("WORLD","BRIDGES_UP") 
		
		# Loading data from the CONFIG about body inner parameters (energy level, etc)
		var loading_world_enery_value = config_file_loaded.get_value("WORLD","energy_value")
		
		# Setting up loaded data into loaded WORLD scene (fix: make it more flexible for other simulations?)
		get_node("/root/MAIN/WORLD/CHARACTER/BODY").BRIDGES_UP = loading_world_BRIDGES_UP 
		get_node("/root/MAIN/WORLD/CHARACTER/BODY").energy_value = loading_world_enery_value 
		
	if 'BRAIN' in section_list:
		# Load data from CONFIG about connections between neurons
		var loading_brain_connection = config_file_loaded.get_value("BRAIN","CONNECTIONS") 
	
		# Loading data from the CONFIG (list of neuron's inned DB dictonaries)
		var loading_brain_data = config_file_loaded.get_value("BRAIN","DATA")
		
		# Loading packed brain scene into roulette
		MAIN.LOAD_BRAIN(catalog_link+"/BRAIN.tscn")

		# Restoring DataField from CONFIG
		get_node("/root/MAIN/BRAIN/GraphEdit").GraphData = loading_brain_data
	
		# Walk trough list of neuron's inned DB dictonaries and connect data
		for node_record in loading_brain_data: 
			#print("Synchronization with the field "+node_record)
			get_node("/root/MAIN/BRAIN/GraphEdit/"+node_record).CONNECT_DATA()
			
		# Restroring connections within the constructor
		for connection_record in loading_brain_connection:
			#print(connection_record) 
			get_node("/root/MAIN/BRAIN/GraphEdit").connect_node(connection_record["from"],connection_record["from_port"],connection_record["to"],connection_record["to_port"] )
			
	#After Brain and Constructor data was restored 
	# Refresh project's directory (fix: singleton)
	MAIN.current_project_catalog = cat_id
	get_node("/root/MAIN/Panel/Current_project_label").text = cat_id

	# Synchronize the bridges eventually
	MAIN.SYNC_WORLD()



# Function for complete saving of project
func SAVE_PROJECT(name="", description=""):
	
	var W_saving_status = false                                                 # WORLD saving status
	var B_saving_status = false                                                 # BRIN saving status
	
	# Lenght of the name should be > 0 to process
	if len(name) > 0: 
		var dir = Directory.new()                                               # DIR variable container
		var config = ConfigFile.new()                                           # CONFIG variable container
		dir.open("res://SAVE/")                                                 # Open SAVE directory container
		dir.make_dir(name)                                                      # Create new directory within the container

		MAIN.current_project_catalog = name                                     #  New value for current project's directory in MAIN.gd
		config.set_value("Settings", "description", description)                # Copy Project's description from manager into CONFIG

		#Save specific data states from WORLD.tscn
		if MAIN.CHECK_WORLD() == true:                                          # If world exist
			print('SAVING System: Found WORLD')
			SAVE_WORLD()                                                        # SAVE WORLD as packedScene
			
			# DUMP data about BRIDGES and energy value into CONF file
			config.set_value("WORLD", "BRIDGES_UP", get_node("/root/MAIN/WORLD/CHARACTER/BODY").BRIDGES_UP )            # Saving ascending bridges (From body to brain) into CONFIG
			config.set_value("WORLD", "energy_value", get_node("/root/MAIN/WORLD/CHARACTER/BODY").energy_value )        # Saving energy value into CONFIG
		
			
			W_saving_status = true                                                                          # WORLD SAVE status 
		else:
			print('SAVING SYSTEM: WORLD not found')

		#BRAIN.tscn
		if get_node("/root/MAIN").CHECK_BRAIN() == true:                                                    # If BRAIN exist
			print('SAVING SYSTEM: I Found the BRAIN')
			SAVE_BRAIN()                                                                                    # SAVE as packedScene
			
			var saving_brain_connections = get_node("/root/MAIN/BRAIN/GraphEdit").get_connection_list()     # Connections
			var saving_brain_data = get_node("/root/MAIN/BRAIN/GraphEdit").GraphData                        # DataField dump

			config.set_value("BRAIN", "CONNECTIONS", saving_brain_connections )                             # Saving BRIDGES state into CONFIG
			
			config.set_value("BRAIN", "DATA",  saving_brain_data)                                           # Saving neurons state (?)
			B_saving_status = true                                                                          # change saving status of the BRAIN
		else:
			print('SAVING SYSTEM: BRAIN not found')
		
		config.save("res://SAVE/"+name+"/Settings.conf")                                                    # Saving  CONF
		print("Settings.conf successfully saved")

		# LABEL on PANEL COLUM: set project's pathway as text
		get_node("/root/MAIN/Panel/Current_project_label").text = name
		
		REFRESH_CATALOG()




# Function is refreshing the savename (up to date and time)
func REFRESH_SAVENAME():
	var tim = OS.get_time()
	var dat = OS.get_date()
	
	# Formating the blocks that make a save name
	if len(str(tim['minute'])) < 2:
		tim['minute'] = "0"+str(tim['minute'])
	if len(str(tim['hour'])) < 2:
		tim['hour'] = "0"+str(tim['hour'])		
	if len(str(tim['second'])) < 2:
		tim['second'] = "0"+str(tim['second'])		
	# / Formating the blocks that make a save name
	
	# Make a new save name of formatted blocks 
	var save_name = str(dat['day'])+str(dat['month'])+str(dat['year'])+"_"+str(tim['hour'])+""+str(tim['minute'])+""+str(tim['second'])

	# Change the saving name field in manager
	$Name_label.text = str(save_name)



# Function is refreshing a tree of the projects 
func REFRESH_CATALOG():
	$Tree.clear()
	var tree_root = $Tree.create_item() 
	tree_root.set_text(0,"res://SAVE/")
	
	# Geting the list of all projects within the common saving directory
	saves = []
	var SAVE_dir = Directory.new()
	SAVE_dir.open("res://SAVE/")
	SAVE_dir.list_dir_begin()
	
	while true:
		var save = SAVE_dir.get_next()
		if save == "":
			break
		elif not save.begins_with("."):
			saves.append(save)
			
	SAVE_dir.list_dir_end()
	saves.sort()
	saves.invert()


	for directory in saves: # Walk trough all of the projects within a common SAVE directory
		print('Working with '+directory)
		# Add as element of the tree
		var save_record = $Tree.create_item(tree_root)
		save_record.set_text(0,directory)
		save_record.add_button(0,load('res://IMG/OPEN_ICO.png')) 


# Main SAVE button
# Rewriting existing with pop-up information about that
# TODO: confirmation
func _on_Button_pressed(): 
	if get_node("/root/MAIN").current_project_catalog == $Name_label.text:      
		$WindowDialog.window_title = "Information"
		$WindowDialog/RichTextLabel2.text = "Project will be rewrited"
		$WindowDialog.popup()
	SAVE_PROJECT($Name_label.text, $Descr_field.text)


# Butto that was pressed in project's tree 
# todo: add different types when necessary
func _on_Tree_button_pressed(item, column, id):
	OPEN_PROJECT(item)


# Button is refreshin savename (up to date)
func _on_Button2_pressed():
	REFRESH_SAVENAME()


# Button is closing manager's window
func _on_Button_close_pressed():
	hide()

