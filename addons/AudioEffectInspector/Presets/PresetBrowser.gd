tool
extends HBoxContainer

var preset_list

func _ready() -> void:
	if !preset_list:
		return
	for _preset in preset_list:
		$Browser.add_item(_preset.name)
	$Browser.add_item("Select Preset")
	$Browser.select(preset_list.size())

func _on_Browser_item_selected(id: int) -> void:
	if id == preset_list.size():
		return
	if $Browser.get_item_count() == preset_list.size() + 1:
		$Browser.remove_item(preset_list.size())
	
	_set_properties(0)
	_set_properties(id)
	get_parent().editor_plugin.refresh()

func _set_properties(id: int) -> void:
	for _property in preset_list[id].keys():
		if _property == "name":
			continue
		get_parent().object[_property] = float(preset_list[id][_property])


func _on_NavigationButton_pressed(extra_arg_0: int) -> void:
	$Browser.select(($Browser.selected + 1) % $Browser.get_item_count())
	_on_Browser_item_selected($Browser.selected)
