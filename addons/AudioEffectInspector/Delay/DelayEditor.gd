extends CenterContainer
tool
var object : AudioEffectDelay
var editor_plugin: EditorPlugin
var color: = Color("f9b338")
var color2: = Color("397ff7")
var color3: = Color("39f7e1")
func _process(delta: float) -> void:
	if !object:
		return
	update()

func _draw() -> void:
	var bound_percent:float = 0.25
	var bounds:Rect2 = Rect2()
	bounds.position.x = (rect_size.x-rect_min_size.x)*0.5
	bounds.size = rect_min_size
	var center:Vector2 = bounds.position + bounds.size * 0.5
	var thirds:Vector2 = bounds.position + bounds.size * Vector2(0.5, 1)
	var half_size:float = bounds.size.x * 0.5
	
	var max_ms:float = 1500.0
	
	if object["feedback/active"]:
		var echo_delay:float = clamp(object["feedback/delay_ms"],1,1500)
		var echo_count:int = ceil(max_ms/echo_delay)
		var current_echo_vol = 0
		var echo_vol_per:float = object["feedback/level_db"]
		var current_lowpass = 0
		var lowpass_per:float = 16000 - object["feedback/lowpass"]
		#var echo_vol_per:float = db2linear(object["feedback/level_db"])
		for echo in range(echo_count):
			var new_color = color2.linear_interpolate(color3, clamp(current_lowpass/16000.0,0,1))
			new_color.a = db2linear(current_echo_vol)
			#new_color.a = range_lerp(current_echo_vol,0,-60,1,0)
			var distance:float = half_size*(echo_delay*echo)/max_ms
			draw_arc(thirds, distance, PI, PI*2, 33, new_color, 1, true)
			current_echo_vol += echo_vol_per
			current_lowpass += lowpass_per
			if current_echo_vol <= -60:
				break
	#draw_arc(thirds, half_size, PI, PI*2, 33, ColorN("white", 0.5), 1, true)
	for tap in ["tap1/", "tap2/"]:
		var tap_active:bool = object[tap+"active"]
		if !tap_active:
			continue
		var tap_ms:float = object[tap+"delay_ms"]
		var tap_pan:float = object[tap+"pan"] if tap != "feedback/" else 0
		var tap_db: float = range_lerp(object[tap+"level_db"], -60, 24, 0, 1)#db2linear(object[tap+"level_db"])
		
		var distance:float = half_size*tap_ms/max_ms
		var line_color = color
		var line_color_trans = color
		line_color_trans.a = 0.5
		draw_arc(thirds, distance, PI, PI*2, 33, line_color_trans, 1, true)
#		draw_arc(thirds, distance, PI, PI*2, 33, line_color, 1, true)
		draw_arc(thirds, distance, lerp(PI*1.5, PI*2, tap_db), lerp(PI*1.5, PI, tap_db), 33, line_color, 2, true)
#		draw_arc(thirds, distance, lerp(PI, PI*1.5, tap_db), PI, 33, line_color, 2, true)
#		draw_arc(thirds, distance, lerp(PI*2, PI*1.5, tap_db), PI*2, 33, line_color, 2, true)
		draw_circle(thirds+(Vector2.UP*distance).rotated(tap_pan*PI*0.5), 3, line_color)
