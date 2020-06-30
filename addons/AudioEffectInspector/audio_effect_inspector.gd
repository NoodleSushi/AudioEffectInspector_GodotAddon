extends EditorInspectorPlugin
var editor_plugin: EditorPlugin

const references = {
	AudioEffectPanner: ["AudioEffectPanner", preload("Panner/PannerScene.tscn")],
	AudioEffectReverb: ["AudioEffectReverb", preload("Reverb/ReverbScene.tscn")],
	AudioEffectEQ: ["AudioEffectEQ", preload("EQ/EQScene.tscn")],
	AudioEffectDelay: ["AudioEffectDelay", preload("Delay/DelayScene.tscn")],
	AudioEffectDistortion: ["AudioEffectDistortion", preload("Distortion/DistortionScene.tscn")]
}

const preset_browser_ref = preload("res://addons/AudioEffectInspector/Presets/PresetBrowser.tscn")

var preset_data = {}

func _init() -> void:
	var file = File.new()
	file.open("res://addons/AudioEffectInspector/Presets/presets.cdb", File.READ)
	preset_data = JSON.parse(file.get_as_text()).result
	file.close()

func can_handle(object: Object) -> bool:
	return object is AudioEffect

func parse_category(object: Object, category: String) -> void:
	for _class in references.keys():
		if !(object is _class && category == references[_class][0]):
			continue
		
		var editor = references[_class][1].instance()
		editor.object = object
		editor.editor_plugin = editor_plugin
		
		if object is AudioEffectEQ:
			editor.band_count = object.get_band_count()
		
		for _sheet in preset_data.sheets:
			if _sheet.name == references[_class][0]:
				var new_browser = preset_browser_ref.instance()
				new_browser.preset_list = _sheet.lines
				editor.add_child(new_browser)
				editor.move_child(new_browser, 0)
				break
		
		add_custom_control(editor)
