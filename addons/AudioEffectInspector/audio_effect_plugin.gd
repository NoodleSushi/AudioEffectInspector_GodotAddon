tool
extends EditorPlugin

var plugin: EditorInspectorPlugin
var edited_audio_effect: AudioEffect

func handles(object):
	return object is AudioEffectPanner

func _enter_tree() -> void:
	plugin = preload("audio_effect_inspector.gd").new()
	plugin.editor_plugin = self
	add_inspector_plugin(plugin)

#func edit(object):
#	if is_instance_valid(edited_audio_effect):
#		edited_vector.disconnect("changed", self, "_on_vector_changed")
#	edited_vector = object
#	edited_vector.connect("changed", self, "_on_vector_changed")

func _exit_tree() -> void:
	remove_inspector_plugin(plugin)

func refresh() -> void:
	get_editor_interface().get_inspector().refresh()
