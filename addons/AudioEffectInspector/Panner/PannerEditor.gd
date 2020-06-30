tool extends CenterContainer

var object : AudioEffectPanner
var editor_plugin: EditorPlugin
var is_pressed = false
func _process(delta: float) -> void:
	if !object:
		return
	var real = (object.pan+1)/2.0
	$ColorRect/Sprite.frame = round(real*32)


func _on_PannerScene_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		is_pressed = event.pressed
	if is_pressed && event is InputEventMouseMotion:
		var x_add = event.relative.x
		object.pan = clamp(object.pan + x_add/56.0, -1, 1)
		editor_plugin.refresh()
