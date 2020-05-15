extends EditorInspectorPlugin
var editor_plugin: EditorPlugin

func can_handle(object: Object) -> bool:
	return object is AudioEffect

func parse_property(object: Object, type: int, path: String, hint: int, hint_text: String, usage: int) -> bool:
#	printt(type, path, hint, hint_text, usage)
	if object is AudioEffectPanner && path == "pan":
		var editor = preload("Panner/PannerScene.tscn").instance()
		editor.object = object
		editor.editor_plugin = editor_plugin
		add_custom_control(editor)
		
	elif object is AudioEffectReverb && path == "room_size":
		var editor = preload("Reverb/ReverbScene.tscn").instance()
		editor.object = object
		editor.editor_plugin = editor_plugin
		add_custom_control(editor)
		
	elif object is AudioEffectEQ && (\
		(path == "band_db/32_hz" && object.get_band_count() == 6) || \
		(path == "band_db/31_hz" && object.get_band_count() == 10) || \
		(path == "band_db/22_hz" && object.get_band_count() == 21)):
		var editor = preload("EQ/EQScene.tscn").instance()
		editor.object = object
		editor.editor_plugin = editor_plugin
		editor.band_count = object.get_band_count()
		add_custom_control(editor)
		
	elif object is AudioEffectDelay && path == "dry":
		var editor = preload("Delay/DelayScene.tscn").instance()
		editor.object = object
		editor.editor_plugin = editor_plugin
		add_custom_control(editor)
	
	return false
