extends GraphNode


var Indicator = 0.0
var potential: float = 0.0
var sum_potential: float = 0.0
var INPUT_COMBO = []

#???
var bridge_source = null # ?? 


# Called when the node enters the scene tree for the first time.
func _ready():
	$ColorRect.color = Color(255,0,0,Indicator)


# Real-time processing of incoming information + UI output
func _physics_process(_delta):
	if Indicator > 0.0: 
		Indicator -= 0.1
		$ColorRect.color = Color(255,0,0,Indicator)
	
	if sum_potential != potential:
		sum_potential = potential
		$Label.text = str(sum_potential)
		#print('AMOTO >> MAKE ', INPUT_COMBO)
		MAKE(INPUT_COMBO)                                                       
		$ColorRect.color = Color(255,0,0)
		Indicator = 1.0
		
		
func _on_GraphNode_close_request():
	queue_free()


func SUMM(input_value, combo):
	
	potential += input_value # summ potential in variable 
	INPUT_COMBO = combo # set incoming data combination into a variable
	



func _on_GraphNode_gui_input(event):
	if event.is_action_pressed("#mouse_left_click") == true:
		MAKE([-1000,-50])

func MAKE(combo):
	# Добавить проверку существования мира иначе вылетает 
	#print('AMOTO: INPUT COMBO')
	#print(combo)
	#print(name)
	#print(title)

	# Тут будет проприоцепторный каскад
	print('Непосредственное выполнение с комбо', combo)
	var result = get_node('/root/MAIN/WORLD/CHARACTER/BODY').EXECUTE(title, combo)      # FUNCTION(title)
	print('result: ', result)
	
	# Сброс пртенциала
	potential = 0.0
	sum_potential = 0.0

