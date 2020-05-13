extends Control
tool
var object = null
var editor_plugin: EditorPlugin
export(float, 0, 1) var room_size = 0
export(float, 0, 1) var damping = 0
export(float, 0, 1) var spread = 0
export(float, 0, 1) var hipass = 0
export(bool) var is_testing = false

func _process(delta: float) -> void:
	var change = false
	if !object && !is_testing:
		return
	if !is_testing:
		change = abs(room_size - object.room_size) + abs(damping - object.damping) + abs(hipass - object.hipass) + abs(spread - object.spread) > 0.0001
		room_size = easer(room_size, object.room_size, 0.0005, delta)
		damping = easer(damping, object.damping, 0.0005, delta)
		hipass = easer(hipass, object.hipass, 0.0005, delta)
		spread = object.spread
	else:
		change = true
	var camera_origin = $ViewportContainer/Viewport/Spatial/CameraOrigin
	camera_origin.rotation.y += delta*0.5
	if !change:
		return
	var room = $ViewportContainer/Viewport/Spatial/Room
	room.mesh.material.roughness = lerp(0.625, 0.21, damping)
	var segments = round(lerp(4, 8, spread))
	room.mesh.radial_segments = segments
	room.rotation.y = PI/float(segments)
	#room.rotate_y(delta*0.8)
	room.scale.x = lerp(1, 3, room_size)
	room.scale.z = lerp(1, 3, room_size)
	room.scale.y = lerp(0.5, 1, room_size)
	$ViewportContainer/Viewport/Spatial/CameraOrigin/Camera.translation.z = lerp(4, 6, room_size)
	camera_origin.rotation_degrees.x = lerp(-90, -32, room_size)
	camera_origin.translation.y = lerp(0, -0.65, room_size)
	$ViewportContainer/Viewport/Spatial/Floor.translation.y = lerp(-0.5, -1, room_size)
	
	for light in room.get_children():
		light.omni_range = lerp(1, 3, room_size)
		light.translation.y = lerp(0, 0, room_size)
		light.light_energy = lerp(0.8, 1, hipass)*lerp(1.3, 1, room_size)

func easer(a: float, b: float, f: float, dt: float) -> float:
	return lerp(a, b, 1 - pow(f, dt))
