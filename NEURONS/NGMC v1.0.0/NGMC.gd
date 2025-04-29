extends GraphNode

# Подключится к корню платформы
onready var MAIN = get_node_or_null("/root/MAIN")

var GraphData # Переменная доступа к глобальному словарю
var NodeData = {} # Переменная которая будет содержать ссылку на ячейку для данной ноды в поле данных


var CHANNELS = {0:null, 1: null}
var READY = false

var neurogram_connection = null


# ТЕХНИЧИСКИЕ ПЕРЕМЕННЫЕ
var popup_monitor = "MONITOR" # Пункт выпадающего меню для передачи данных в осцилограф 

var neuron_full_path # ???
var LIMITER = false  # ???
var Indicator = 0.0  # ???

# СЛОВАРЬ СВЯЗЕЙ {СОСЕД: ВЕС} (заменено на поле данных)
#var Connections_inhibition = {}  # Словарь возбуждающих связей для данной ноды, содержит имя ноды и вес связи
#var Connections_exhibition = {}  # Словарь погашающих связей для данной ноды, содержит имя ноды и вес связи


# Начальное значение потенциала текущего нейрона
var potential : float = 0.0


# Тип нейрона
var node_type = "NGMC" # ХВАТИТ ЛИ УКАЗАНИЯ В КОРНЕ?

# Начальное значение Порог активации нейрона
var activation_level: float = 0.0

# Начальное значение для индикатора нейрона
var Recatangle_light = 0 # ПО-умолчанию индикатор не активен







# Инициализация нейрона
func _ready():

	neuron_full_path = self.get_path()

	CONNECT_DATA()
	
	# Установить базовое значение индикатора
#	$ColorRect.color = Color(Recatangle_light)
	#print(typeof(potential))
	################07022022$ColorRect.color = Color(255,255,255,NodeData["Params"]["Indicator"])
	# Установить базовые значения текстовых индикаторов 
	#$Label3.text = "P: "+str(potential)
	$CURRENT.text = "P: "+str(potential)
	
	
	
	
	# Установить значения выпадающего меню
	$PopupMenu.add_item("CONNECT SELECTED")
	$PopupMenu.add_item("MANAGE")
	$PopupMenu.add_item(popup_monitor)
	$PopupMenu.add_item("DATA")
	$PopupMenu.add_item("NEUROGRAM")




func CONNECT_DATA():
	print()
	#MAIN.ADD_TO_CONSOLE('F: CONNECT_DATA()', true)
	print('F: CONNECT_DATA() for '+ name)
	
	#Получить доступ к полю данных, которое находится в корневой ноде конструктора
	GraphData = get_parent().GraphData
	
	#MAIN.ADD_TO_CONSOLE('Current DF state::')
	print("Текущее поле данных конструктора: ")
	print(GraphData)
	
	# Если системное имя данной ноды находится в поле данных
	if name in GraphData:
		# В общем ничего делать не нужно на данный момент
		#MAIN.ADD_TO_CONSOLE('Node exist in the DF!')
		print('Существует информация о данной ноде в поле')
	# Но если запись о этой ноде не обнаружена в поле данных
	else:
		# Это срабатывает когда нода создается впервые или до того как будет обновлен ДФ при загрузке
		#MAIN.ADD_TO_CONSOLE('Node still not in the DF')
		print('Информация о ноде отсутствует в поле')
		
		# РЕГИСТРАЦИЯ ЯЧЕЙКИ В ПОЛЕ ИНФОРМАЦИИ
		# Создать новый объект ячейку непосредственно в поле
		GraphData[name] = {} 
		# Создать раздел с подключениями для данной ноды в ее ячейке 
		GraphData[name]["Connections"] = {0:{}, 1:{}}
		#GraphData[name]["Connections"] = {}
		# Создать раздел со значением SpinBox (сила импульса) и определить текущую
		GraphData[name]["Params"] = {}
		
		# Тут нужно передать значения которые нода имеет в самом начале ? (В поле данных вносится первичные значения)
		##%$GraphData[name]["Params"]["potential"] = potential
		##$%GraphData[name]["Params"]["activation_level"] = activation_level
		GraphData[name]["Params"]["Indicator"] = Indicator
		GraphData[name]["Params"]["Potential"] = potential
		GraphData[name]["Params"]["Activation_level"] = activation_level

	
	
	
	# БЛОК ИНТЕГРАЦИИ С ПОЛЕМ ИНФОРМАЦИИ
	
	# определить NodeData как ссылку на ячейку в поле ??? нужно ли
	NodeData = GraphData[name] 
	
	# ТУТ НУЖНО ПРИСВОИТЬ ИНТЕГРИРОВАННЫЕ ПАРАМЕТРЫ В ИНТЕРФЕЙС НОДЫ
	$ColorRect.color = Color(255,255,255,NodeData["Params"]["Indicator"])
	#$Label3.text = "P: "+str(NodeData["Params"]["Potential"])
	$CURRENT.text = "P: "+str(NodeData["Params"]["Potential"])
	$ACTIVATION_LVL.text = "AL: "+str(NodeData["Params"]["Activation_level"])
	# / БЛОК ИНТЕГРАЦИИ С ПОЛЕМ ИНФОРМАЦИИ
	
	
	print("Новое состояние поля :")
	MAIN.ADD_TO_CONSOLE("", true)
	MAIN.ADD_TO_CONSOLE("Current DF state + \n")
	
	# Отобразить новое состояние в консоли
	for DF_item in GraphData:
		MAIN.ADD_TO_CONSOLE(DF_item)
		MAIN.ADD_TO_CONSOLE("   " + str(GraphData[DF_item]))
		
	print(GraphData)
	#print(name)
	#print(NodeData)
	print('/ F: CONNECT_DATA()')
	print()









# ФУНКЦИЯ АКТИВИРУЕТСЯ КОГДА ПРОИСХОДИТ НАЖАТИЕ НА НОДУ ЛЕВОЙ КНОПКОЙ
func _on_GraphNode_gui_input(event):
	if event.is_action_pressed("mouse_left_click") == true:
		print('clicked')	
		#SIGMOID(0.6) # Активация функции возбуждения
	if event.is_action_pressed("mouse_right_click") == true:
		#print('right clicked')
		#popup_menu.clear()
		#popup_menu.add_item("Connect to monitor", PopupIds.SHOW_LAST_MOUSE_POSITION)
		#popup_menu.add_item("Test")

		$PopupMenu.popup( Rect2( get_global_mouse_position(), Vector2(10,10) ) )
		#SIGMOID(0.6) # Активация функции возбуждения
		pass
		
		
		
		
		
#func SUMM(input_value):
#	print('Возбуждение')
#	print('POT ', NodeData["Params"]["Potential"])
#	print('SUMM ', input_value)
#	NodeData["Params"]["Potential"] += input_value
#	$ColorRect.color = Color(0,0,255)
#	print('NEW_POT ', NodeData["Params"]["Potential"])

#func DECR(input_value):
#	print('POT ', NodeData["Params"]["Potential"])
#	print('DECR ', input_value)
#	NodeData["Params"]["Potential"] -= input_value
#	$ColorRect.color = Color(255,0,0)
#	print('NEW_POT ', NodeData["Params"]["Potential"])
#	#get_tree().quit()

# Функция инициации канала
func INIT(channel_id, input_value):
	print('инициализация канала')
	print(channel_id)
	print(input_value)
	CHANNELS[channel_id] = input_value
	
	get_node("Label_ch"+str(channel_id)).text = str(input_value)
	
	print('канал инициализирован, текущее состояние')
	print(CHANNELS)
	var chan_values = CHANNELS.values()
	
	
	if null in chan_values:
		pass
		print('Каналы еще не заполнены')
	else:
		print('Каналы заполнены')
		READY = true
		

	
	
	

# Жизненный цикл нейрона NGMC
func _physics_process(_delta):

	if READY == true:
		print('READY true')
		if NodeData["Connections"].size() > 0: # Если у нейрона существуют возбуждающие связи
			if neurogram_connection == true:
				get_tree().root.get_node("MAIN/NEUROGRAMMA").CALL_CELL(name)
			#print('Список связей')
			#print(Connections_inhibition)
			for NEIGH in NodeData["Connections"][0]: # Пройти по каждому соседу в списке связей
				print("SPIKE! TO ", NEIGH)
				
				
	#				# Убедится в существовании ноды
				var receiver_node = get_parent().get_node_or_null(NEIGH)
	#				# Если нода существует
				if receiver_node != null:
					print('СОСЕД ОБНАРУЖЕН!')
		#>>>		# >>>> Получить доступ к целевому нейрону и активировать функцию возбуждения
					var CHAN_COMBO = [] 
					for CHAN_KEY in CHANNELS.keys():
						CHAN_COMBO.append(CHANNELS[ CHAN_KEY ])
					print('КОМБИНАЦИЯ БУДЕТ ОТПРАВЛЕНА:', CHAN_COMBO)
					get_parent().get_node(NEIGH).SUMM(1.0, CHAN_COMBO)  # .SUMM(NodeData["Params"]["Activation_level"], CHAN_COMBO) 
					$ColorRect.color = Color(255,255,255)
					NodeData["Params"]["Indicator"] = 1.0
					
					for CHAN_ID in CHANNELS.keys():
						CHANNELS[CHAN_ID] = null
					print('Комбинация успешно отправлено, каналы деинициализированы')
					print(CHANNELS)
					$Label_ch0.text = "Null"
					$Label_ch1.text = "Null"
					
					
	#				# Если нода не существует
				elif receiver_node == null:
					print('СОСЕД НЕ ОБНАРУЖЕН')
	#					# Тут нужно удалить запись о соседе из поля информации
					get_parent().GraphData[name]["Connections"].erase(NEIGH)
					print('ЗАПИСЬ УДАЛЕНА!')
					print()
					#get_tree().quit()
	READY = false
	








""""
# Жизненный цикл нейрона
func _physics_process(_delta):
	#print(activation_level)
	#print(potential)
	if NodeData["Params"]["Indicator"] > 0.0: 
		NodeData["Params"]["Indicator"] -= 0.1
		$ColorRect.color = Color(255,255,255,NodeData["Params"]["Indicator"])
		print(NodeData["Params"]["Indicator"])
		
	# Обновление current potential statement text indicator 
	#$Label3.text = "P: "+str(NodeData["Params"]["Potential"])
	$CURRENT.text = "P: "+str(NodeData["Params"]["Potential"])
	$ACTIVATION_LVL.text = "AL: "+str(NodeData["Params"]["Activation_level"])
	Recatangle_light -= 10
	#$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
	
	
	# (+-+) Калий-натриевый насос, поддержка нейрона в стабильном состоянии
	#Если потенциал больше нуля но не достиг уровня активации 
	if NodeData["Params"]["Potential"] > -0.001:
		#print("POT-")
		NodeData["Params"]["Potential"] -= 0.001
		if NodeData["Params"]["Potential"] - 0.001 < 0:
			NodeData["Params"]["Potential"] == 0.001
	if NodeData["Params"]["Potential"] < -0.00001:
		#print("POT+")
		NodeData["Params"]["Potential"] += 0.00001
	# (+-+) Калий-натриевый насос, поддержка нейрона в стабильном состоянии	


	# Постипенное уменьшение порога активации
	if NodeData["Params"]["Activation_level"] > 0.00001:
		#print("AL-")
		NodeData["Params"]["Activation_level"] -= 0.0000001
	# Если потенциал меньше нуля
	elif NodeData["Params"]["Activation_level"] < 0.00001:
		#print("AL+")
		NodeData["Params"]["Activation_level"] += 0.00001

	

	if NodeData["Params"]["Potential"] > NodeData["Params"]["Activation_level"]:
		#print("spike: ", potential, " > ", activation_level )
		# ВОЗБУЖДАЮЩИЙ КАНАЛ
		if NodeData["Connections"].size() > 0: # Если у нейрона существуют возбуждающие связи
			if neurogram_connection == true:
				get_tree().root.get_node("MAIN/NEUROGRAMMA").CALL_CELL(name)
			#print('Список связей')
			#print(Connections_inhibition)
			for NEIGH in NodeData["Connections"]: # Пройти по каждому соседу в списке связей
				print("SPIKE! TO ", NEIGH)
				
				
#				# Убедится в существовании ноды
				var receiver_node = get_parent().get_node_or_null(NEIGH)
#				# Если нода существует
				if receiver_node != null:
					print('СОСЕД ОБНАРУЖЕН!')
		#>>>		# >>>> Получить доступ к целевому нейрону и активировать функцию возбуждения
					var CHAN_COMBO = [] 
					for CHAN_KEY in CHANNELS.keys():
						CHAN_COMBO.append(CHANNELS[ CHAN_KEY ])
					print('КОМБИНАЦИЯ БУДЕТ ОТПРАВЛЕНА:', CHAN_COMBO)
					get_parent().get_node(NEIGH).SUMM(NodeData["Params"]["Activation_level"], CHAN_COMBO) 
					$ColorRect.color = Color(255,255,255)
					NodeData["Params"]["Indicator"] = 1.0
					
#				# Если нода не существует
				elif receiver_node == null:
					print('СОСЕД НЕ ОБНАРУЖЕН')
#					# Тут нужно удалить запись о соседе из поля информации
					get_parent().GraphData[name]["Connections"].erase(NEIGH)
					print('ЗАПИСЬ УДАЛЕНА!')
					print()
					#get_tree().quit()
				
				
				
#				# Получить доступ к целевому нейрону и активировать функцию возбуждения
#				get_parent().get_node(NEIGH).SUMM(NodeData["Params"]["Activation_level"]) 				
#				$ColorRect.color = Color(255,255,255)
#				NodeData["Params"]["Indicator"] = 1.0






				var AL_incr_percentage = NodeData["Params"]["Potential"] * 0.00001
				NodeData["Params"]["Potential"] -= NodeData["Params"]["Activation_level"] #0.01
				NodeData["Params"]["Activation_level"] += AL_incr_percentage #0.00001
				
				###Connections_inhibition[NEIGH] = int(Connections_inhibition[NEIGH]) + 1 # Увеличение веса
				#print('Увеличен вес, новый вес для '+ NEIGH + " : "+ str(Connections_inhibition[NEIGH]))
				#get_node('/root/MAIN/GraphEdit/'+NEIGH).Recatangle_light = -
				#Recatangle_light = 0
				#$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
				









	# Обновление current potential statement text indicator 
	#$Label3.text = "P: "+str(NodeData["Params"]["Potential"])
	$CURRENT.text = "P: "+str(NodeData["Params"]["Potential"])
	$ACTIVATION_LVL.text = "AL: "+str(NodeData["Params"]["Activation_level"])
"""


"""

	# Если текущий потенциал больше или равен порогу активации
	if potential > activation_level:
		#Recatangle_light = 255
		#$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
		
		#current_potential = potential
		# Следует назначить новый порог активации (заменить на текущий потенциал)



		# ВОЗБУЖДАЮЩИЙ КАНАЛ
		if Connections_inhibition.size() > 0:
			print('Список связей')
			print(Connections_inhibition)
			# Пройти по каждому соседу в списке связей
			for NEIGH in Connections_inhibition: 
				Recatangle_light = 200
				$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
				#get_node('/root/MAIN/GraphEdit/'+NEIGH).potential += 1.0
				get_parent().get_node(NEIGH).SUMM(activation_level)
				Connections_inhibition[NEIGH] = int(Connections_inhibition[NEIGH]) + 1
				print('Увеличен вес, новый вес для '+ NEIGH + " : "+ str(Connections_inhibition[NEIGH]))
				#get_node('/root/MAIN/GraphEdit/'+NEIGH).Recatangle_light = -
				#Recatangle_light = 0
				#$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)

			
				
		# ПОГАШАЮЩИЙ КАНАЛ
		if Connections_exhibition.size() > 0:
			print('Список связей')
			print(Connections_exhibition)
			# Пройти по каждому соседу в списке связей
			for NEIGH in Connections_exhibition: 
				Recatangle_light = 200
				$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
				#get_node('/root/MAIN/GraphEdit/'+NEIGH).potential += 1.0
				get_parent().get_node(NEIGH).DECR(activation_level)
				Connections_exhibition[NEIGH] = int(Connections_exhibition[NEIGH]) - 1 # ЭТО ВЕС В СПИСКЕ ВЯЗЕЙ
				print('Уменьшен вес, новый вес для '+ NEIGH + " : "+ str(Connections_exhibition[NEIGH]))
				#get_node('/root/MAIN/GraphEdit/'+NEIGH).Recatangle_light = -
				#Recatangle_light = 0
				#$ColorRect.color = Color(Recatangle_light,Recatangle_light,Recatangle_light)
				
		potential -= activation_level # Тут отнимаю от текущего потенциала только что отправленный сигнал
		activation_level += 0.00001 # Тут я медленно повышаю порог после каждого спайка, тут я заменил плавное возрастание activation_level = potential
		print('Новый порог ', activation_level)
"""





func _on_PopupMenu_id_pressed(id):
	var item_name = $PopupMenu.get_item_text(id)
	print(item_name)
	if item_name == popup_monitor:
		print("CONNECTING")
		#get_node("/root/MAIN/Panel/SPERCTRUM/Label2").text = str(name)+" CONNECTED"
		get_node("/root/MAIN/Panel/SPERCTRUM").connected_neuron = neuron_full_path

	if item_name == 'DATA':
		print('DATA')
		MAIN.ADD_TO_CONSOLE('', true)
		MAIN.ADD_TO_CONSOLE(GraphData)


	if item_name == 'MANAGE':
		get_node("/root/MAIN").MANAGE_NODE(name)
	
	if item_name == 'CONNECT SELECTED':
		# Подключить все выделенные ноды к этой 
		print(get_parent().selected())
		#get_node("/root/MAIN").MANAGE_NODE(name)
		
		
	if item_name == 'NEUROGRAM':
		get_node("/root/MAIN/NEUROGRAMMA").REG_NEURON(name)
		neurogram_connection = true


func _on_INHIBITION_close_request():
	# УДАЛИТЬ ЗАПИСЬ ИЗ ОБЩЕГО ПОЛЯ ИНФОРМАЦИИ
	GraphData.erase(name)
	# Закрыть ноду
	queue_free()
	pass # Replace with function body.




func _on_CURRENT_pressed():
	print(potential)
	get_tree().root.get_node("MAIN").START_VALUE_CHANGER(str(NodeData["Params"]["Potential"]), [name,"Potential"] ) #Отправляю так же ключ который будет воздействовать на поле данных
	pass # Replace with function body.


func _on_ACTIVATION_LVL_pressed():
	get_tree().root.get_node("MAIN").START_VALUE_CHANGER(str(NodeData["Params"]["Activation_level"]), [name,"Activation_level"] ) #Отправляю так же ключ который будет воздействовать на поле данных
	pass # Replace with function body.


# При изменении текста
#func _on_LineEdit_text_changed(new_text):
#	NSA_DATABLOCK = $datablock_input.text
#	$Current_datablock.text = NSA_DATABLOCK
#	print('changed')
#	pass # Replace with function body.
