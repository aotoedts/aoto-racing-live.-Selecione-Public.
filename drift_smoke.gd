extends Node3D
## Low-cost stylized drift smoke; reusable mesh pool (no GPU particles).
var puffs: Array[MeshInstance3D] = []
var age: Array[float] = []
var active: Array[bool] = []
var cursor := 0
const COUNT := 24

func _ready() -> void:
	for i in range(COUNT):
		var mesh := SphereMesh.new()
		mesh.radius = 0.42
		mesh.height = 0.84
		mesh.radial_segments = 8
		mesh.rings = 4
		var puff := MeshInstance3D.new()
		puff.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.62, 0.69, 0.83, 0.42)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		puff.material_override = mat
		puff.visible = false
		add_child(puff)
		puffs.append(puff)
		age.append(0.0)
		active.append(false)

func emit_at(pos: Vector3) -> void:
	var puff := puffs[cursor]
	puff.global_position = pos
	puff.scale = Vector3.ONE
	puff.visible = true
	age[cursor] = 0.0
	active[cursor] = true
	cursor = (cursor + 1) % COUNT

func _process(delta: float) -> void:
	for i in range(COUNT):
		if not active[i]:
			continue
		age[i] += delta
		if age[i] > 1.2:
			active[i] = false
			puffs[i].visible = false
		else:
			puffs[i].position.y += delta * 0.55
			puffs[i].scale = Vector3.ONE * (1.0 + age[i] * 1.5)
