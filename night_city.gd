extends Node3D
## Original cyber-night city details and fake wet-road reflections.
## Procedural meshes: no assets copied from reference games.
var high_quality := true
var reflection_nodes: Array[MeshInstance3D] = []
var lamp_nodes: Array[OmniLight3D] = []

func _mat(color: Color, glow := false, transparent := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = 0.7
	m.roughness = 0.12
	if glow:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 2.5
	if transparent:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(size: Vector3, pos: Vector3, color: Color, glow := false, transparent := false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	mesh.position = pos
	mesh.material_override = _mat(color, glow, transparent)
	add_child(mesh)
	return mesh

func _ready() -> void:
	var road := _box(Vector3(34, 0.03, 360), Vector3(0, -0.13, -110), Color("#182137"))
	var road_mat := road.material_override as StandardMaterial3D
	road_mat.roughness = 0.08
	for i in range(34):
		var z := 40.0 - float(i) * 10.0
		for side in [-1, 1]:
			var s := float(side)
			var h := 10.0 + float((i * 7) % 9) * 3.0
			var x := s * (24.0 + float(i % 3) * 5.0)
			_box(Vector3(7.5, h, 7.0), Vector3(x, h / 2.0, z), Color("#14192c"))
			for floor_id in range(int(h / 3.0)):
				var y := 2.5 + floor_id * 3.0
				var tint := Color("#15cfff") if (i + floor_id) % 3 == 0 else Color("#fc35bd")
				_box(Vector3(0.12, 0.65, 1.3), Vector3(x - s * 3.8, y, z - 1.9), tint, true)
				_box(Vector3(0.12, 0.65, 1.3), Vector3(x - s * 3.8, y, z + 1.9), tint, true)
			if i % 2 == 0:
				var neon := Color("#fa28b8") if i % 4 == 0 else Color("#08d7ff")
				_box(Vector3(0.5, 6.0, 0.5), Vector3(s * 16.2, 3, z), Color("#293246"))
				_box(Vector3(1.4, 0.25, 0.5), Vector3(s * 16.2, 6, z), neon, true)
				var reflection := _box(Vector3(1.8, 0.015, 7.5), Vector3(s * 13.7, -0.10, z), Color(neon.r, neon.g, neon.b, 0.38), true, true)
				reflection_nodes.append(reflection)
				if i < 8:
					var light := OmniLight3D.new()
					light.position = Vector3(s * 16.0, 5.5, z)
					light.light_color = neon
					light.light_energy = 1.2
					light.omni_range = 13
					add_child(light)
					lamp_nodes.append(light)
	for i in range(18):
		var z := 35.0 - float(i) * 18.0
		_box(Vector3(0.1, 0.015, 9.0), Vector3(-8.0, -0.10, z), Color(0.04, 0.5, 0.9, 0.3), true, true)
		_box(Vector3(0.1, 0.015, 9.0), Vector3(8.0, -0.10, z), Color(0.9, 0.08, 0.5, 0.3), true, true)

func set_detail(enabled: bool) -> void:
	high_quality = enabled
	for reflection in reflection_nodes:
		reflection.visible = enabled
	for lamp in lamp_nodes:
		lamp.visible = enabled
