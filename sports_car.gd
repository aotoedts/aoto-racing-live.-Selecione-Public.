extends Node3D
## Original low-poly sports car made entirely from built-in meshes.
@export var paint: Color = Color("#ff365e")
var wheels: Array[Node3D] = []

func _mat(color: Color, glow := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = 0.55
	m.roughness = 0.24
	if glow:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.5
	return m

func _part(size: Vector3, pos: Vector3, color: Color, glow := false) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	part.mesh = box
	part.position = pos
	part.material_override = _mat(color, glow)
	add_child(part)
	return part

func _ready() -> void:
	_part(Vector3(2.65, 0.5, 5.0), Vector3(0, 0.82, 0), paint)
	_part(Vector3(2.35, 0.18, 1.1), Vector3(0, 0.58, -2.05), paint)
	_part(Vector3(2.05, 0.65, 2.25), Vector3(0, 1.35, -0.25), Color("#101827"))
	_part(Vector3(1.9, 0.12, 1.45), Vector3(0, 1.73, -0.35), paint.darkened(0.3))
	_part(Vector3(2.85, 0.12, 0.5), Vector3(0, 1.4, 2.1), paint)
	_part(Vector3(1.7, 0.12, 0.18), Vector3(0, 1.68, 2.1), paint)
	_part(Vector3(1.9, 0.12, 0.2), Vector3(0, 0.63, -2.5), Color("#202632"))
	# Aerodynamic bodywork, underglow, exhaust and additional LED details.
	_part(Vector3(2.55, 0.18, 0.22), Vector3(0, 0.55, -2.57), Color("#080b13"))
	_part(Vector3(2.4, 0.12, 0.35), Vector3(0, 0.48, 2.53), Color("#080b13"))
	for x in [-1.05, 1.05]:
		_part(Vector3(0.13, 0.19, 3.2), Vector3(x, 0.72, 0), paint.darkened(0.25))
		_part(Vector3(0.18, 0.10, 1.6), Vector3(x, 1.14, -0.9), Color("#121a2a"))
		_part(Vector3(0.36, 0.15, 0.25), Vector3(x, 1.43, -0.65), paint)
		_part(Vector3(0.18, 0.35, 0.2), Vector3(x, 1.40, 1.94), Color("#111520"))
	_part(Vector3(2.0, 0.055, 3.7), Vector3(0, 0.25, 0), Color("#11bfff"), true)
	_part(Vector3(1.65, 0.055, 0.08), Vector3(0, 0.98, 2.56), Color("#fa2e5e"), true)
	for x in [-0.85, 0.85]:
		_part(Vector3(0.3, 0.16, 0.18), Vector3(x, 0.49, 2.58), Color("#777e8d"))
	for x in [-0.95, 0.95]:
		_part(Vector3(0.55, 0.15, 0.16), Vector3(x, 0.88, -2.53), Color("#c5f9ff"), true)
		_part(Vector3(0.5, 0.13, 0.14), Vector3(x, 0.88, 2.53), Color("#ff284d"), true)
	for x in [-1.28, 1.28]:
		for z in [-1.5, 1.5]:
			var wheel := Node3D.new()
			wheel.position = Vector3(x, 0.47, z)
			add_child(wheel)
			var tire := MeshInstance3D.new()
			var cylinder := CylinderMesh.new()
			cylinder.top_radius = 0.49
			cylinder.bottom_radius = 0.49
			cylinder.height = 0.35
			tire.mesh = cylinder
			tire.rotation.z = PI / 2
			tire.material_override = _mat(Color("#0c0e15"))
			wheel.add_child(tire)
			var rim := MeshInstance3D.new()
			var rim_mesh := CylinderMesh.new()
			rim_mesh.top_radius = 0.29
			rim_mesh.bottom_radius = 0.29
			rim_mesh.height = 0.37
			rim.mesh = rim_mesh
			rim.rotation.z = PI / 2
			rim.material_override = _mat(Color("#b3c3d9"))
			wheel.add_child(rim)
			wheels.append(wheel)

func spin(delta: float, speed: float) -> void:
	for wheel in wheels:
		wheel.rotation.x += delta * speed * 0.45
