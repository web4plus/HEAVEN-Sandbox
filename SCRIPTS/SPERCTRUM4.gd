extends Node2D




var potential_percentage # Это процент, который будет отображать долю потенциала от общего уровня активации




#var chill_lvl = 50 # Уровень отображения потенциала покоя (-0.0001)



# ПЕРЕМЕННЫЕ ПОДКЛЮЧАЕМОГО НЕЙРОНА
var connected_neuron = null


# ПЕРЕМЕННЫЕ ЛИНИИ УРОВНЯ АКТИВАЦИИ 
var activation_line_lvl = 25
var activation_line_start #= Vector2(0,activation_line_lvl)
var activation_line_end #= #Vector2(1128,activation_line_lvl) 
var activation_line_color = Color(200,0,255)



# ПЕРЕМЕННЫЕ ЛИНИИ УРОВНЯ ПОКОЯ
var chill_line_lvl = 75
var chill_line_start #= Vector2(0,activation_line_lvl)
var chill_line_end #= #Vector2(1128,activation_line_lvl) 
var chill_line_color = Color(0,100,255)



# ПЕРЕМЕННЫЕ РАЗМЕРА ПОЛЯ
var field_size_y
var field_size_x



# ПЕРЕМЕННЫЕ ТЕКУЩЕЙ ЛИНИИ
var position_x 
var position_y 

var rect_list = [] # Общий список всех точек белой линии
var prev_point # Начало нового участка белой линии (предидущая точка)
#var start_position # Стартовая точка для белой линии
var spectrum_color = Color(255,255,255) # Цвет белой линии
var last_rect_obj



#ПЕРЕМЕННЫЕ КРАСНОЙ ЛИНИИ
var previous_rect_list = []
var previous_prev_point #Начало нового участка красной линии (предидущая точка)
#var previous_start_position # Стартовая точка для красной линии
var previous_spectrum_color =  Color(255,0,0, 0.6) # Цвет красной линии
var last_prev_rect_obj





# Called when the node enters the scene tree for the first time.
func _ready():

	# Установить значения переменных размера рабочего пространства
	field_size_y = int($ColorRect.rect_size.y)
	field_size_x = int($ColorRect.rect_size.x)
	
	# Установить начальную точку для самого первого запуска
	#start_position = [0, field_size_y]# +$HSlider.value]
	
	# Установить значение стартовой точки в качестве предидущей точки  ??
	prev_point = [0, chill_line_lvl]####int($HSlider.value)]
	
	# Установит значения  стартовой точки в качестве текущей позиции ??
	position_x = -1
	position_y = chill_line_lvl #0
	print('Y ',position_y)
	get_node("/root/MAIN").ADD_TO_CONSOLE(str(position_y))
	# Установить значения для линии активации
	activation_line_start = Vector2(0,activation_line_lvl)
	activation_line_end = Vector2(field_size_x,activation_line_lvl) 
	$ACTIVATION_LVL.text = "0.0" # str(activation_line_lvl)

	# Установить значения для линии покоя
	chill_line_start = Vector2(0,chill_line_lvl)
	chill_line_end = Vector2(field_size_x,chill_line_lvl) 
   





func _draw(): # Функция отрисовки
	
	# ОТРИСОВАТЬ КРАСНУЮ ЛИНИЮ
	#print('Предидущий список') 
	#print(previous_rect_list)
	if len(previous_rect_list) > 0:
		
		for previous_rect_obj in previous_rect_list: # Пройти по списку точек [  [x,y], [x,y], [x,y]  ]
			draw_line(Vector2(previous_prev_point[0],previous_prev_point[1]), Vector2(previous_rect_obj[0],previous_rect_obj[1]), previous_spectrum_color, 2.0) # Нарисовать линию
			previous_prev_point = previous_rect_obj # Обновить значение предидущей точки
			#last_prev_rect_obj = previous_rect_obj
		previous_prev_point = [0,previous_rect_list[0][1]] # ТУТ НУЖЕН ПЕРВЫЙ ОБЪЕКТ А НЕ ПОСЛЕДНИЙ last_prev_rect_obj[1]] # Сброс что бы не отрисовывалась доп линия???????
	

	# ОТРИСОВАТЬ БЕЛУЮ ЛИНИЮ
	if len(rect_list) > 0: # Если список точке больше чем 0, это означает что появились изменения и можно составить как минимум одну линию
		for rect_obj in rect_list: # Пройти по списку точек [  [x,y], [x,y], [x,y]  ]

			#print(rect_obj)
		# отрисовать от первой до второй, от второй до третьей, от третьей до четвертой итL
			draw_line(Vector2(prev_point[0],prev_point[1]), Vector2(rect_obj[0],rect_obj[1]), spectrum_color, 2.0) # Нарисовать линию
			prev_point = rect_obj # Обновить значение предидущей точки
			last_rect_obj = rect_obj
		prev_point = [0,rect_list[0][1]]    # ТУТ ПО КАКОЙ-то ПРИЧИНЕ ПРОИСХОДИТ ОТРИСОВКА КАЖДЫЙ РАЗ  Сюда нужно поместить значение крайней точки rect_list[-1][1]]#start_position # Сброс что бы не отрисовывалась доп линия
	

	# ОТРИСОВКА ПОРОГА АКТИВАЦИИ
	draw_line(activation_line_start, activation_line_end, activation_line_color, 1.0) # Нарисовать линию

	# ОТРИСОВКА ПОРОГА ПОКОЯ
	draw_line(chill_line_start, chill_line_end, chill_line_color, 1.0) # Нарисовать линию






# ФУНКЦИЯ СРАБАТЫВАЕТ ПОСЛЕ ИЗМЕНЕНИЙ В САЙДБАРЕ
func _on_HSlider_value_changed(value):

	$Label.text =  str($HSlider.value)
	position_y =  $HSlider.value # Значение (высота) точки




# ПРОДВИЖЕНИЕ ГРАФИКА ВПЕРЁД ПО ДЕЛЬТЕ
func _physics_process(_delta):
	if connected_neuron != null:
		
		# Информация (какой нейрон подключен)
		$Label2.text = connected_neuron
		# Отображение уровня активации
		$ACTIVATION_LVL.text = str(get_node(connected_neuron).NodeData["Params"]["Activation_level"])
		$POTENTIAL_LVL.text = str(get_node(connected_neuron).NodeData["Params"]["Potential"])

		
		
		#################
		position_x += 1 #  Смещение с каждым шагом итеррации на один пикс
		  
		# Высчитать процент потенциала от уровня активации
		
		potential_percentage = (get_node(connected_neuron).NodeData["Params"]["Potential"] / get_node(connected_neuron).NodeData["Params"]["Activation_level"]) * 100 
		# Получить значение уровня линии (позиции по У) на основе высчитанного процента
		$PERCENTAGE.text = str(potential_percentage)+" %"
		position_y = chill_line_lvl -  ( 50 *  potential_percentage /100  )  #get_node(connected_neuron).potential
		$PERCENTAGE2.text = str( 50 *  potential_percentage /100  )
		
		if position_y > field_size_y: position_y = field_size_y
		if position_y < 0: position_y = 0

		# ЕСЛИ ПОЗИЦИЯ ВЫХОДИТ ЗА РАМКИ РАБОЧЕГО ПРОСТРАНСТВА КОНЕЦ ПРОХОДА
		if position_x > field_size_x: 
		#for xxx in rect_list:
		#	print(xxx)
		#queue_free()
		#Очистить список предидущей (красной линии)
			previous_rect_list = [] 

		# Перенести текущую линию в красную 
			for trans_value in rect_list: 
				previous_rect_list.append(trans_value)
			
			
		#Определить первую предидущую точку (для первого сегмента) для красной линии
			previous_prev_point = [0, previous_rect_list[0][1]]
		#previous_start_position =  [0, rect_list[-1][1]]
		
		
		# Сбросить белую линию в начало
			position_x = 0
		
		
		# Очистить список текущей линии
			rect_list = []
		# Переназначить предидущую точку
			prev_point = [0,position_y]
		
		print(prev_point)
		rect_list.append([position_x, position_y]) # Добавить новую точку в общий список точек
		update()	
		pass


