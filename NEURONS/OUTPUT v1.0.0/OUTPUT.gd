extends GraphNode


var Indicator = 0.0

var potential: float = 0.0
var sum_potential: float = 0.0

#WORLD/BODY'
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(255,0,0,Indicator)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GraphNode_close_request():
	queue_free()
	pass # Replace with function body.


func SUMM(input_value):
	potential += input_value

	

func _physics_process(_delta):
	if Indicator > 0.0: 
		Indicator -= 0.1
		$ColorRect.color = Color(255,0,0,Indicator)
		#220225###########print(Indicator)
		
		
	
	if sum_potential != potential:
		sum_potential = potential
		$Label.text = str(sum_potential)
		MAKE()
		$ColorRect.color = Color(255,0,0)
		Indicator = 1.0


func _on_GraphNode_gui_input(event):
	if event.is_action_pressed("mouse_left_click") == true:
		pass #MAKE()

func MAKE():
	# Добавить проверку существования мира иначе вылетает 
	#220225###########print('clicked')
	#220225###########print(name)
	#220225###########print(title)
	get_node('/root/MAIN/WORLD/CHARACTER/BODY').FUNCTION(title)
	potential = 0.0
	#SIGMOID(0.6) # Активация функции возбуждения	
