tool extends Node


var object : AudioEffectDistortion
var editor_plugin: EditorPlugin

var rec_drive : int = -1
var rec_mode : int = -1
var pre_gain : float = 0
var post_gain : float = 0

onready var Line := $ColorRect/Line2D as Line2D

#REFERENCE:
#https://github.com/godotengine/godot/blob/master/servers/audio/effects/audio_effect_distortion.cpp
func get_amp(out : float) -> float:
	if !object:
		return 0.0
	var pre = db2linear(object.pre_gain)
	var post = db2linear(object.post_gain)
	var a : float = out * pre
	var d : float = object.drive
	match object.mode:
		object.MODE_CLIP:
			var x = sign(a)
			a = clamp(pow(a, 1.0001 - d) * x, -1.0, 1.0)
		object.MODE_ATAN:
			var atan_mult = pow(10, d * d * 3.0) - 1.0 + 0.001;
			var atan_div = (atan(atan_mult) * (1.0 + d * 8))
			a = atan(a * atan_mult) / atan_div;
		object.MODE_LOFI:
			var lofi_mult = pow(2.0, 2.0 + (1.0 - d) * 14)
			a = floor(a * lofi_mult + 0.5) / lofi_mult
		object.MODE_OVERDRIVE:
			var x = a * 0.686306;
			var z = 1 + exp(sqrt(abs(x)) * -0.75)
			a = (exp(x) - exp(-x * z)) / (exp(x) + exp(-x))
		object.MODE_WAVESHAPE:
			var x = a
			var k = 2 * d / (1.00001 - d)
			a = (1.0 + k) * x / (1.0 + k * abs(x))
	return a * post

func _ready() -> void:
	update()

func _process(delta: float) -> void:
	if !object:
		return
	if rec_drive != object.drive || rec_mode != object.mode || pre_gain != object.pre_gain || post_gain != object.post_gain:
		update()

func update() -> void:
	rec_drive = object.drive
	rec_mode = object.mode
	pre_gain = object.pre_gain
	post_gain = object.post_gain
	Line.clear_points()
	for i in range(129):
		Line.add_point(Vector2(i, -64 - clamp(get_amp((i-64)/64.0), -1, 1)*64))
	editor_plugin.refresh()

var mouse_pressed = false

func _on_ColorRect_gui_input(event: InputEvent) -> void:
	if !object:
		return
	if event is InputEventMouseButton:
		mouse_pressed = (event as InputEventMouseButton).pressed
	if mouse_pressed && event is InputEventMouseMotion:
		object.drive -= (event as InputEventMouseMotion).relative.y/128.0
		object.drive = clamp(object.drive, 0, 1)
		update()
