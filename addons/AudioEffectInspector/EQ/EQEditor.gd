tool
extends Control


enum MODE {PENCIL, LINE, CURVE}

const DB_MIN: int = -60
const DB_MAX: int = 24
const DB_PAGE: int = 36
const CURVE_SEARCH: int = 6
const color1: Color = Color("#e0e0e0")
const color2: Color = Color(1,1,1,0.2)
const color3: Color = Color(1,1,1,0.05)

var band_count: int = 0
var selected_band_idx: int = 0
var pressed_left: bool = false
var pressed_right: bool = false
var leveller_left_pressed: bool = false
var scroll_is_scrolling: bool = false
var line_points: Array = [Vector2(), Vector2()]
var mode: int = MODE.PENCIL

var object: AudioEffectEQ
var editor_plugin: EditorPlugin
onready var min_node: SpinBox = $DbScroll/Min
onready var max_node: SpinBox = $DbScroll/Max
onready var scroll_node: VScrollBar = $EQEditor/VScrollBar
onready var space_node: Control = $EQEditor/Space


func _ready() -> void:
	scroll_node.step = 1
	scroll_node.rounded = true
	scroll_node.min_value = DB_MIN
	scroll_node.max_value = DB_MAX
	scroll_node.page = DB_PAGE
	min_node.value = -18
	max_node.value = 18
	_on_DrawStateButton_pressed(MODE.PENCIL)
	update()


func _on_Space_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		pressed_left = event.pressed
		line_points[0] = event.position
		if mode == MODE.LINE:
			var newx = stepify(line_points[0].x, space_node.rect_size.x/float(band_count)) + space_node.rect_size.x/float(band_count*2)
			line_points[0].y = x_to_line_points_y(newx)
			line_points[0].x = newx

	if event is InputEventMouseButton && event.button_index == BUTTON_RIGHT:
		pressed_right = event.pressed

	if event is InputEventMouse && (pressed_left || pressed_right):
		var band_index = Space_x_to_band_index(event.position.x)

		if pressed_right:
			object.set_band_gain_db(band_index, 0)
			editor_plugin.refresh()
			return
		
		if mode == MODE.PENCIL || mode == MODE.CURVE:
			selected_band_idx = band_index
			var new_db = Space_y_to_db(event.position.y)
			object.set_band_gain_db(band_index, new_db)
			
			var old_idx = Space_x_to_band_index(line_points[0].x)
			var new_idx = Space_x_to_band_index(event.position.x)
			if abs(old_idx - new_idx) > 0:
				var old_db = object.get_band_gain_db(old_idx)
				for band_idx in range(min(old_idx, new_idx) + 1, max(old_idx, new_idx)):
					object.set_band_gain_db(band_idx, range_lerp(band_idx, old_idx, new_idx, old_db, new_db))
			
			line_points[0] = event.position
			editor_plugin.refresh()

		elif mode == MODE.LINE:
			line_points[1] = event.position
			var editor_space_size: Vector2 = space_node.rect_size
			var m = (line_points[1].y - line_points[0].y) / (line_points[1].x - line_points[0].x)
			# var p1 = Vector2(0, m * (0 - line_points[0].x) + line_points[0].y)
			# var p2 = Vector2(editor_space_size.x, m * (editor_space_size.x - line_points[0].x) + line_points[0].y)

			for band_idx in range(band_count):
				var idx = [Space_x_to_band_index(line_points[0].x), Space_x_to_band_index(line_points[1].x)]
				if band_idx >= min(idx[0], idx[1]) && band_idx <= max(idx[0], idx[1]):
					object.set_band_gain_db(
						band_idx, 
						Space_y_to_db(x_to_line_points_y(band_index_to_Space_x(band_idx, 0.5)))
						#db_from_y(m * (x_from_band_index(band_idx, 0.5) - line_points[0].x) + line_points[0].y)
					)

			editor_plugin.refresh()


func _on_Leveller_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		leveller_left_pressed = event.pressed

	if event is InputEventMouseMotion && leveller_left_pressed:
		var db_move_scale: float = abs(float(max_node.value - min_node.value))/space_node.rect_size.y
		var db_move_translation: float = -event.relative.y*db_move_scale
		for band_idx in range(band_count):
			object.set_band_gain_db(band_idx, clamp(object.get_band_gain_db(band_idx)+db_move_translation, DB_MIN, DB_MAX))
		editor_plugin.refresh()


func _process(delta: float) -> void:
	if pressed_left && !pressed_right && mode == MODE.CURVE:
		for search_range in range(1, int(band_count)):
			var upper_bound = selected_band_idx + search_range
			#var weight = clamp(250*delta / (search_range*50), 0, 1)
			var weight = pow(2, -search_range) * delta * 10
			if upper_bound < band_count:
				var new_db = lerp(object.get_band_gain_db(upper_bound), object.get_band_gain_db(upper_bound-1), weight)
				object.set_band_gain_db(upper_bound, new_db)

			var bottom_bound = selected_band_idx - search_range
			if bottom_bound >= 0:
				var new_db = lerp(object.get_band_gain_db(bottom_bound), object.get_band_gain_db(bottom_bound+1), weight)
				object.set_band_gain_db(bottom_bound, new_db)
			
		editor_plugin.refresh()
	update()


func _draw() -> void:
	draw_set_transform(space_node.rect_position, 0, Vector2.ONE)
	var editor_space_size: Vector2 = space_node.rect_size

	#DRAW LINE TEST
#	if line_points[1].x != line_points[0].x:
#		var m = (line_points[1].y - line_points[0].y) / (line_points[1].x - line_points[0].x)
#		var p1 = Vector2(0, m * (0 - line_points[0].x) + line_points[0].y)
#		var p2 = Vector2(editor_space_size.x, m * (editor_space_size.x - line_points[0].x) + line_points[0].y)
#		draw_line(p1, p2, Color.red)
#		draw_circle(line_points[0], 2, Color.red)

	#DRAW LINE GUIDES
	for line_db in range(-60, 24, 6):
		if line_db < min_node.value || line_db > max_node.value:
			continue
		var y_pos = range_lerp(line_db, max_node.value, min_node.value, 0, editor_space_size.y)
		draw_line(Vector2(0, y_pos), Vector2(editor_space_size.x, y_pos), color2 if line_db == 0 else color3)
		
	#DRAW BANDS
	var band_width = editor_space_size.x/float(band_count)
	for band_idx in range(band_count):
		var band_db = object.get_band_gain_db(band_idx)
		if band_db < min_node.value:
			continue
		draw_band(
			Rect2(
				band_width*band_idx,
				editor_space_size.y,
				band_width,
				range_lerp(min(band_db, max_node.value), min_node.value, max_node.value, 0, -editor_space_size.y)
			),
			color1,
			color3,
			min_node.value == DB_MIN,
			band_db <= max_node.value
		)


func draw_band(rect: Rect2, _color: Color, _color2: Color, draw_bottom: bool, draw_top: bool) -> void:
	draw_rect(rect, _color2, true)
	draw_line(rect.position, Vector2(rect.position.x, rect.end.y), _color)
	draw_line(rect.end, Vector2(rect.end.x, rect.position.y), _color)
	if draw_bottom:
		draw_line(rect.position, Vector2(rect.end.x, rect.position.y), _color)
	if draw_top:
		draw_line(rect.end, Vector2(rect.position.x, rect.end.y), _color)


func Space_x_to_band_index(x: float) -> int:
	return int(clamp(floor(x*band_count/space_node.rect_size.x), 0, band_count-1))


func band_index_to_Space_x(band_idx: int, phase: float = 0) -> float:
	return ((band_idx + phase) * space_node.rect_size.x) / float(band_count)


func Space_y_to_db(y: float) -> float:
	return range_lerp(
		clamp(y, 0, space_node.rect_size.y), 
		0, 
		space_node.rect_size.y, 
		max_node.value, 
		min_node.value
	)


func line_points_get_m() -> float:
	if (line_points[1].x - line_points[0].x) != 0:
		return (line_points[1].y - line_points[0].y) / (line_points[1].x - line_points[0].x)
	return 0.0


func x_to_line_points_y(x_pos: float) -> float:
	return line_points_get_m() * (x_pos - line_points[0].x) + line_points[0].y


#TODO: FIX SCROLL BAR INVERSE
#Update the scroll bar based on the Min and Max spin boxes
func update_ScrollBar() -> void:
	if scroll_is_scrolling:
		return
	scroll_node.page = abs(max_node.value - min_node.value)
	scroll_node.value = min_node.value


#Make sure the min max scroll page stays consistent, foo states direction I guess
func normalize_minmax_scroll(foo : bool) -> void:
	if abs(max_node.value - min_node.value) < DB_PAGE && (max_node.value == DB_MAX || foo):
		min_node.value = max_node.value - DB_PAGE
	if abs(max_node.value - min_node.value) < DB_PAGE && (min_node.value == DB_MIN || !foo):
		max_node.value = min_node.value + DB_PAGE


#Update the Min and Max spin boxes when the scroll bar changes
func _on_VScrollBar_value_changed(scroll_value: float) -> void:
	scroll_is_scrolling = true
	var current_page : int = abs(min_node.value - max_node.value)
	min_node.value = scroll_value
	max_node.value = scroll_value + current_page
	scroll_is_scrolling = false
	editor_plugin.refresh()


func _on_DrawStateButton_pressed(type: int) -> void:
	mode = type
	for child_idx in range($DrawStateButtons.get_child_count()):
		$DrawStateButtons.get_child(child_idx).pressed = child_idx == type


#Update alternate values based on change, make page consistent, and update the scrollbar
func _on_Min_value_changed(min_value: float) -> void:
	if min_value > max_node.value:
		max_node.value = min_value + DB_PAGE
	normalize_minmax_scroll(false)
	update_ScrollBar()
	editor_plugin.refresh()


func _on_Max_value_changed(max_value: float) -> void:
	if min_node.value > max_value:
		min_node.value = max_value - DB_PAGE
	normalize_minmax_scroll(true)
	update_ScrollBar()
	editor_plugin.refresh()
