extends RigidBody2D


########### SETTINGS & VARIABLES ##########################

var thrust = Vector2(0,-50)            # Basic value for thrust (movement impulse variable)
var energy_value = 18.0                # ENERGY starting value 
var energy_color = Color(0,0,0)        # ENERGY color container
var coords_switch = true               # DRAW COORDS toggle
var MOUTH_objects = []                 #??? Could be used somewhere else, mouth temp container

# Variables for drag & dropwith a mouse
var is_dragging = false 
var mouse_offset = Vector2() 

########### / SETTINGS & VARIABLES ########################






############ BRIDGES PROTOCOL ##################

#SENSORY BRIDGES ^^^
onready var BRIDGES_UP = {
	
	# Interoreceptors of the CORE block
	"ENRG_green": null,
	"ENRG_green_incr": null,
	"ENRG_red": null,
	"ENRG_red_decr": null,
	
	# Facial exteroreceptors
	"MOUNTH": null,
	"RS": null,
	"LS": null,
	"RS_big": null,
	"LS_big": null,
	"FIB_L": null,
	"FIB_R": null,
	
	
	# Skin exteroreceptors
	"LEFT_1": null,
	"LEFT_2": null,
	"LEFT_3": null,
	"LEFT_4": null,
	"RIGHT_1": null,
	"RIGHT_2": null,
	"RIGHT_3": null,
	"RIGHT_4": null,
	
	# Vestibular 
	"VSTB_L1": null,
	"VSTB_L2": null,
	"VSTB_L3": null,
	"VSTB_R1": null,
	"VSTB_R2": null,
	"VSTB_R3": null,
	
	# Vision
	"L_RET1": null,
	"L_RET2": null,
	"L_RET3": null,
	"L_RET4": null,
	"L_RET5": null,
	
	"R_RET1": null,
	"R_RET2": null,
	"R_RET3": null,
	"R_RET4": null,
	"R_RET5": null,
}


#MOTOR BRIDGES VVV
onready var BRIDGES_DOWN = {
	"LEFT": {"aM": {"Type":"AMOTO", "Node":null}, 
			 "aS": {"Type":"ASENSE", "Node":null}
			},
	"RIGHT": {"aM": {"Type":"AMOTO", "Node":null}, 
			 "aS": {"Type":"ASENSE", "Node":null}
			},
	"EAT": {"aM": {"Type":"AMOTO", "Node":null}, 
			 "aS": {"Type":"ASENSE", "Node":null}
			},
}

############ / BRIDGES PROTOCOL ##################



# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)                                                     # is it input-sensetive
	$Energy_loss.start()                                                        # Basic energy loss



# DRAW system elements, such as energy level, vestibular, etc
func _draw():

	draw_circle(Vector2(0,0),energy_value, energy_color)  # Draw ENERGY circle from the middle of body
	
	# If switch true ==>  Draw COORDS (Vestibular) 
	if coords_switch == true:
		
		# Draw coords cross
		draw_line(Vector2( 0, 75), Vector2(0,-75), Color(0,0,255))
		draw_line(Vector2( -75, 0), Vector2( 75, 0), Color(0,0,255))
	
		# Draw vector direction
		var rotatated_linear_velocity = - linear_velocity.rotated(- get_rotation())
		draw_line(Vector2( 0, 0), rotatated_linear_velocity, Color(255,255,255))
	
		# Draw vector direction red circle
		draw_circle(rotatated_linear_velocity, 6.0, Color(255,0,0))
	


# INPUT processing (manual control) 
func _input(event):
	
	if event.is_action_pressed("ui_up"):
		FUNCTION('move')
	if event.is_action_pressed("ui_space"):
		FUNCTION('eat')
	if event.is_action_pressed("ui_right"):
		FUNCTION('right')
	if event.is_action_pressed("ui_left"):
		FUNCTION('left')
	if event.is_action_pressed("ui_down"):
		FUNCTION('back')
		
	if event is InputEventMouseButton: #1
		if event.button_index == BUTTON_LEFT: #1
			if event.pressed: #1
				if get_global_transform().xform(Vector2.ZERO).distance_to(get_global_mouse_position()) < 10: #1
					is_dragging = true #1
					print('DRAGGING TRUE') #1
					mouse_offset = global_position - get_global_mouse_position() #1
				else: #1
					is_dragging = false #1



######################## (!) ⚠️⚠️TRANSFER SIGNAL TROUGH THE BRIDGES ########################
func GET_BRIDGE(receptor, data, strenght ):
	if BRIDGES_UP[receptor] != null:                                            # Если объект из локальной записи существует
		####0402222321print("BRIDGE with "+ receptor +" has been found")
		if get_node_or_null(BRIDGES_UP[receptor]) != null:
			####0402222321print('Bridge connected: True')
			get_node(BRIDGES_UP[receptor]).SEND_IMPULSE(strenght, data)         # 
		else:
			####0402222321print('Bridge does not exis anymore')
			BRIDGES_UP[receptor] = null                                         # Roveking local record of the bridge
	else:
		####0402222321print('Bridge wasn't found)
		pass


# Единая функция доступа к мостам
func GET_MOTO_BRIDGE(FEV, data, strenght, ret_channel="aS" ):
	print('GETMOTO BRIDGE: ', FEV, data, strenght, ret_channel)
	if BRIDGES_DOWN[FEV] != null: # Если объект из локальной записи существует
		####0402222321print("BRIDGE с "+ receptor +" обнаружен")
		
		print(BRIDGES_DOWN)
		print(BRIDGES_DOWN[FEV])
		print(BRIDGES_DOWN[FEV]["aS"]["Node"])
		
		if get_node_or_null(BRIDGES_DOWN[FEV]["aS"]["Node"]) != null:
			print('MOTO Мост подтверждён')
			get_node(BRIDGES_DOWN[FEV]["aS"]["Node"]).SEND_IMPULSE(strenght, data) # передача по мосту
		else:
			print('MOTO Мост больше не существует')
			BRIDGES_DOWN[FEV]["aS"]["Node"] = null # Сброс локальной записи о мосте 
	else:
		print('MOTO Мост не обнаружен')
		pass


######################## / (!) ⚠️⚠️TRANSFER SIGNAL TROUGH THE BRIDGES ########################


# Функция регулирует энергообмен внутри существа
func ENERGY(val):
	var result_energy

	result_energy = energy_value + val 

	# Изменение уровня энергетического уровня
	if result_energy > 20 or result_energy == 20:
		result_energy = 19.99
	if result_energy < -20 or result_energy == -20:
		result_energy = -19.99

	energy_value = result_energy

	
	# Тут нужно отправлять сигналы о вхождении некоторого значения
	
	if val > 0:
		GET_BRIDGE("ENRG_green_incr",val, 0.01)
	elif val < 0:
		GET_BRIDGE("ENRG_red_decr", val, 0.01)
	
	
	# Изменение цвета отрисовки груга показателя энергии в зависимости от шкалы -20 < 0 > +20
	if energy_value > 0: 
		####0402222321print('Больше нуля, активирую')
		energy_color = Color(0,255,0)
		#GET_BRIDGE("ENRG_green", null, energy_value/100)
		GET_BRIDGE("ENRG_green",int( energy_value), 0.01)

	elif energy_value < 0: 
		####0402222321print('Меньше нуля, активирую')
		####0402222321print('Направляемое значение ', abs(energy_value/100))
		energy_color = Color(255,0,0)	
		#GET_BRIDGE("ENRG_red", null, abs(energy_value/100))
		GET_BRIDGE("ENRG_red", int(energy_value), 0.01)
		# Так же стимулировать ядро насыщения
		if val > 0:
			#GET_BRIDGE("ENRG_green", null, energy_value/100)
			GET_BRIDGE("ENRG_green", int(energy_value), 0.01)
	
	update()
	get_node("ENER").text = str(energy_value)



# Тестовая область МА / #############################

# Функция установки занчения проприоцептора для F в поле информации
func SET_PROPRIO(F_name, R_value):
	null

# Функция расчёта возвратного значения F и ранее заданного проприоцептора	
func GET_PROPRIO(F_name, A_value):
	null


# Главная функция выполнения, проприоцепторный каскад
func EXECUTE(func_name, args):
	# Произвести выполнение функции и захватить возвращаемое значение
	print('EXECUTE')
	print(func_name)
	print(args)
	var RETURN_VALUE = callv(func_name, args)
	
	print('PROPRIO RETURN FOR ASENSE: ', RETURN_VALUE)
	# тут следует добавить сигнал ASENSE который будет сообщать об обратной связи
	print('Выполняю обращение к мосту ', func_name, RETURN_VALUE)
	GET_MOTO_BRIDGE(func_name, RETURN_VALUE, 0.1)
	# Эксперементальная интеграция МЭВ через ФЭВ
	# Выполнить проприоцепторную функцию и захватить значение
	# 10 aug 2023 var PROPRIO_VALUE = GET_PROPRIO(func_name, RETURN_VALUE)
	# Отправить проприоцепторное значение через GET_BRIDGE или другой метод
	# GET_BRIDGE(func_name, PROPRIO_VALUE, 0.01)
	pass



# Тестовое моторное дерево 
func LEFT(torque, thrust):
	print('NEW LEFT FUNCTION ACTIVATED')
	# Небольшой поворот с движением вперёд
	torque = float(torque)
	thrust = float(thrust)
	apply_torque_impulse(torque)       #(-1000)
	var thrust_ready = Vector2(0, thrust)    #,-50)
	apply_impulse(Vector2(0,0), thrust_ready.rotated(get_rotation()))
	# При совершении движения затрачивается энергия
	ENERGY(-0.00005)
	print('LEFT RETURN ', [torque, thrust])
	return [torque, thrust]


func RIGHT(torque, thrust):
	print('NEW RIGHT FUNCTION ACTIVATED')
	# Небольшой поворот с движением вперёд
	torque = float(torque)
	thrust = float(thrust)
	apply_torque_impulse(torque)       #(-1000)
	var thrust_ready = Vector2(0, thrust)    #,-50)
	apply_impulse(Vector2(0,0), thrust_ready.rotated(get_rotation()))
	# При совершении движения затрачивается энергия
	ENERGY(-0.00005)
	print('RIGHT RETURN ', [torque, thrust])
	return [torque, thrust]

func EAT(arg1, arg2):
	
	if len($MOUNTH.get_overlapping_bodies() ) > 0:
		print('FOOD IN MOUTH') 
		
	#thrust = Vector2(0,-150)
	#apply_impulse(Vector2(0,0), thrust.rotated(get_rotation()))
	# При совершении движения затрачивается энергия
	#energy_value -= 0.5
	#update()
	
	# Тут нужно передавать объектам уведомление о взаимодействии, это будет симулятивно корректнее 
	
		$MOUNTH.get_overlapping_bodies()[0].ACTION()
		###ENERGY(2) о повышении энергии должен сообщать объект еды через гет парент
	else:
		print('NOTHING TO EAT')



# /Тестовая область МА #############################


# Главное моторное дерево (примитивный мозжечок?? нет, набор ЭВ)
func FUNCTION(arg):
	#print('FUNCTION ACTIVATED')
	if arg == 'left':
		apply_torque_impulse(-1000)
		# При совершении движения затрачивается энергия
		#energy_value -= 0.05
		#update()
		
		
		thrust = Vector2(0,-50)
		apply_impulse(Vector2(0,0), thrust.rotated(get_rotation()))
		# При совершении движения затрачивается энергия
		#energy_value -= 0.1
		#update()

		ENERGY(-0.00005)


	if arg == 'right':
		apply_torque_impulse(1000)
		# При совершении движения затрачивается энергия
		#energy_value -= 0.05
		#update()
		
		thrust = Vector2(0,-50)
		apply_impulse(Vector2(0,0), thrust.rotated(get_rotation()))
		# При совершении движения затрачивается энергия
		#energy_value -= 0.1
		#update()

		ENERGY(-0.00005)
		
	if arg == 'move':
		thrust = Vector2(0,-50)
		apply_impulse(Vector2(0,0), thrust.rotated(get_rotation()))
		# При совершении движения затрачивается энергия
		#energy_value -= 0.1
		#update()
		ENERGY(-0.0001)

	if arg == 'back':
		thrust = Vector2(0,50)
		apply_impulse(Vector2(0,0), thrust.rotated(get_rotation()))
		# При совершении движения затрачивается энергия
		#energy_value -= 0.1
		#update()
		ENERGY(-0.0001)


		
		
		print("move success")
		
	if arg == 'eat':
		
		if len($MOUNTH.get_overlapping_bodies() ) > 0:
			print('FOOD IN MOUTH') 
		
		# Тут нужно передавать объектам уведомление о взаимодействии, это будет симулятивно корректнее 
		
			$MOUNTH.get_overlapping_bodies()[0].ACTION()
			###ENERGY(2) о повышении энергии должен сообщать объект еды через гет парент
		else:
			print('NOTHING TO EAT')
		



class LEFT_class:

	# конструктор класса с несколькими параметрами
	func _init( proprio_s , requested_m , actual_s ):
		# Подключенная сенсорная нода:
		#self.proprio_sense =  proprio_s

		# Требуемое значение (проприоцептор)
		#self.requested_moto =  requested_m
		null
		# Актуальное значение
		#self.actual_sense =  actual_s

	# Задать проприоцептор
	func SET( input ):
		self.requested_moto = input

	# Получить проприоцепторные данные 
	func GET():
		# тут нужен алгоритм расчёта и затем GET_BRIDGE
		var output = self.actual_sense - self.requested_moto
		#CHARACTER_tree.GET_BRIDGE( self.proprio_sense , output  )
		call("GET_BRIDGE", 'lol')
		# И обнуление.. тут не нужно, поскольку проприо будет активироваться каждый раз когда 



var LEFT = LEFT_class.new(0, 0, 0)




####### Функциональность рецепторов
func _on_MOUNTH_body_entered(body):
	#body.show()
	GET_BRIDGE("MOUNTH", null, 0.1)




func _on_RS_body_entered(body):
	#body.show()
	GET_BRIDGE("RS", null, body.mass/3)


func _on_LS_body_entered(body):
	#body.show()
	GET_BRIDGE("LS", null, body.mass/3)

func _on_LS_big_body_entered(body):
	#body.show()
	GET_BRIDGE("LS_big", null, body.mass/6)

func _on_RS_big_body_entered(body):
	#body.show()
	GET_BRIDGE("RS_big", null, body.mass/6)







# СЕНСОРЫ КОЖНОЙ ЧУСТВИТЕЛЬНОСТИ
func _on_LEFT_1_body_entered(body):
	#body.show()
	GET_BRIDGE("LEFT_1", null, 0.01)



func _on_LEFT_2_body_entered(body):
	#body.show()
	GET_BRIDGE("LEFT_2", null, 0.01)


func _on_LEFT_3_body_entered(body):

	#body.show()
	GET_BRIDGE("LEFT_3", null, 0.01)



func _on_LEFT_4_body_entered(body):
	#body.show()
	GET_BRIDGE("LEFT_4", null, 0.01)



func _on_RIGHT_1_body_entered(body):
	#body.show()
	GET_BRIDGE("RIGHT_1", null, 0.01)



func _on_RIGHT_2_body_entered(body):
	#body.show()
	GET_BRIDGE("RIGHT_2", null, 0.01)



func _on_RIGHT_3_body_entered(body):
	#body.show()
	GET_BRIDGE("RIGHT_3", null, 0.01)


func _on_RIGHT_4_body_entered(body):
	#body.show()
	GET_BRIDGE("RIGHT_4", null, 0.01)


# / СЕНСОРЫ КОЖНОЙ ЧУСТВИТЕЛЬНОСТИ

# Вибриссы

func _on_FIB_L_body_entered(body):
	GET_BRIDGE("FIB_L", null, 0.01)



func _on_FIB_R_body_entered(body):
	GET_BRIDGE("FIB_R", null, 0.01)


func _on_Energy_loss_timeout():

	ENERGY(-0.1)



func _on_Vestibular_rotate_timeout():
	var angular_velocity_limited = 0
	

	# Тут следует направлять значение angular_velocity с позитивным значением, по адресу в зависимости от знака значения
	if int(angular_velocity) > 0:
		if abs(int(angular_velocity)) > 10: 
			angular_velocity_limited = 10
		else:
			angular_velocity_limited = abs(int(angular_velocity))
		GET_BRIDGE('VSTB_R1', angular_velocity_limited, 0.01)
		
		
	elif int(angular_velocity) < 0:
		if abs(int(angular_velocity)) > 10: 
			angular_velocity_limited = 10
		else:
			angular_velocity_limited = abs(int(angular_velocity))
		GET_BRIDGE('VSTB_L1', angular_velocity_limited, 0.01)


func _physics_process(_delta):
	if is_dragging:
		global_position = get_global_mouse_position()+mouse_offset
		mode = RigidBody2D.MODE_KINEMATIC
	else:
		mode= RigidBody2D.MODE_RIGID




func _on_ENERGY_timeout():
	ENERGY(0)


func _on_Vestibular_impulse_timeout():
	#### 10052023 print("Сила ", linear_velocity.length())
	$Linear_Strenght.text = "Strenght: " + str(linear_velocity.length())

	#### 10052023 print("Угол ", linear_velocity) 
	$Linear.text = "Linear: " + str(linear_velocity)
	$Rotation.text = "Rotation: " + str(get_rotation()) 

	
	# Блок выбора области воздействия в зависимости от вектора и развернутого графика
	var rotatated_linear_velocity = - linear_velocity.rotated(- get_rotation())
	var vestibular_area_field = rad2deg(Vector2(0,-75).angle_to(rotatated_linear_velocity) ) 
	var vestibular_area_name = []
	
	var L1 = "VSTB_L2"
	var L2 = "VSTB_L3"
	var R1 = "VSTB_R2"
	var R2 = "VSTB_R3"
	
	
	# Если длина вектора больше минимального значения: определить актвные поля
	if linear_velocity.length() > 1:
		# блок определение области в зависимости от угла вектора 
		if vestibular_area_field > -22.5 and vestibular_area_field < 22.5:
			vestibular_area_name = [L1, R1]
			
		elif vestibular_area_field > 22.5 and vestibular_area_field < 67.5:
			vestibular_area_name = [R1]
			
		elif vestibular_area_field > 67.5 and vestibular_area_field < 112.5:
			vestibular_area_name = [R1, R2]
			
		elif vestibular_area_field > 112.5 and vestibular_area_field < 157.5:
			vestibular_area_name = [R2]
			
		elif vestibular_area_field > -157.5 and vestibular_area_field < -112.5:
			vestibular_area_name = [L2]
			
		elif vestibular_area_field > -112.5 and vestibular_area_field < -67.5:
			vestibular_area_name = [L1, L2]
			
		elif vestibular_area_field > -67.5 and vestibular_area_field < -22.5:
			vestibular_area_name = [L1]
		
		else:
			vestibular_area_name = [L2, R2]
	
	# Определить DATA
	var DATA 
	
	DATA = int(linear_velocity.length()/100)
	if DATA > 10: DATA = 10
	
	# Текстовый лейбл
	if coords_switch == true:
		get_parent().get_parent().get_node("DEGREE").text = str(vestibular_area_name)

	# Связь с мостом
	for area_name in vestibular_area_name:
		GET_BRIDGE(area_name, DATA, 0.01)

