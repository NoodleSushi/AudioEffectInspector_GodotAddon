extends Control
tool


export(float, 0, 1) var room_size: float = 0
export(float, 0, 1) var damping: float = 0
export(float, 0, 1) var spread: float = 0
export(float, 0, 1) var hipass = 0
export(bool) var is_testing = false

var object: AudioEffectReverb
var editor_plugin: EditorPlugin
onready var camera_origin: Spatial = $ViewportContainer/Viewport/Spatial/CameraOrigin
onready var camera_node: Camera = $ViewportContainer/Viewport/Spatial/CameraOrigin/Camera
onready var room_node: MeshInstance = $ViewportContainer/Viewport/Spatial/Room
onready var floor_node: Position3D = $ViewportContainer/Viewport/Spatial/Floor


func _process(delta: float) -> void:
	var change: bool = false
	if !object && !is_testing:
		return
	if !is_testing:
		#change = abs(room_size - object.room_size) + abs(damping - object.damping) + abs(hipass - object.hipass) + abs(spread - object.spread) > 0.0001
		var value_change: float = 0
		for property in ["room_size", "damping", "hipass", "spread"]:
			value_change += abs(self[property] - object[property])
		change = value_change > 1e-4
		room_size = easer(room_size, object.room_size, 0.0005, delta)
		damping = easer(damping, object.damping, 0.0005, delta)
		hipass = easer(hipass, object.hipass, 0.0005, delta)
		spread = object.spread
	else:
		change = true
	camera_origin.rotation.y += delta*0.5
	if !change:
		return
	room_node.get_surface_material(0).roughness = lerp(0.625, 0.21, damping)
	var segments = round(lerp(4, 16, spread))
	room_node.mesh.radial_segments = segments
	room_node.rotation.y = PI/float(segments)
	#room_node.rotate_y(delta*0.8)
	room_node.scale.x = lerp(1, 3, room_size)
	room_node.scale.z = lerp(1, 3, room_size)
	room_node.scale.y = lerp(0.5, 1, room_size)
	camera_node.translation.z = lerp(4, 6, room_size)
	camera_origin.rotation_degrees.x = lerp(-90, -32, room_size)
	camera_origin.translation.y = lerp(0, -0.65, room_size)
	floor_node.translation.y = lerp(-0.5, -1, room_size)
	
	for light in room_node.get_children():
		light.omni_range = lerp(1, 3, room_size)
		light.translation.y = lerp(0, 0, room_size)
		light.light_energy = lerp(0.8, 1.05, hipass)*lerp(1.3, 1, room_size)


func easer(a: float, b: float, f: float, dt: float) -> float:
	return lerp(a, b, 1 - pow(f, dt))
