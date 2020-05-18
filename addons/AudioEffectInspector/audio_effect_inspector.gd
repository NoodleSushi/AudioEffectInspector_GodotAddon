extends EditorInspectorPlugin
var editor_plugin: EditorPlugin

const references = {
	AudioEffectPanner: ["AudioEffectPanner", preload("Panner/PannerScene.tscn")],
	AudioEffectReverb: ["AudioEffectReverb", preload("Reverb/ReverbScene.tscn")],
	AudioEffectEQ: ["AudioEffectEQ", preload("EQ/EQScene.tscn")],
	AudioEffectDelay: ["AudioEffectDelay", preload("Delay/DelayScene.tscn")],
}

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
		add_custom_control(editor)
