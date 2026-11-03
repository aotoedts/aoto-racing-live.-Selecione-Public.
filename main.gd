extends Node3D

# Prototipo 3D offline: sem integracao TikTok.
var mode := 0
var elapsed := 0.0
var nitro := 0.0
var effect := 0.0
var cars: Array[Node3D] = []
var status_label: Label

func _ready() -> void:
	_build_world()
	_build_ui()

func _box(parent: Node3D, size: Vector3, pos: Vector3, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh
	mesh_instance.position = pos
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh_instance.material_override = mat
	parent.add_child(mesh_instance)

func _build_world() -> void:
	_box(self, Vector3(32, 0.2, 180), Vector3(0, -0.2, -65), Color(0.07, 0.08, 0.13))
	for i in range(30):
		var z := 20.0 - float(i) * 6.0
		_box(self, Vector3(0.22, 0.02, 2.8), Vector3(0, 0, z), Color(0.3, 0.9, 1))
		for side in [-1, 1]:
			_box(self, Vector3(0.2, 0.4, 6), Vector3(float(side) * 14, 0.1, z), Color(0.65, 0.1, 0.9))
			var height := 3.0 + float(i % 5) * 2.0
			_box(self, Vector3(3, height, 4), Vector3(float(side) * 20, height / 2, z), Color(0.07, 0.13, 0.23))
	for i in range(2):
		var car := Node3D.new()
		add_child(car)
		_box(car, Vector3(2.3, 0.65, 4), Vector3(0, 0.85, 0), Color(0.96, 0.13, 0.32) if i == 0 else Color(0.1, 0.8, 0.95))
		_box(car, Vector3(1.7, 0.65, 1.8), Vector3(0, 1.45, -0.3), Color(0.05, 0.07, 0.14))
		for x in [-1.15, 1.15]:
			for z in [-1.2, 1.2]:
				_box(car, Vector3(0.28, 0.65, 0.75), Vector3(x, 0.45, z), Color(0.025, 0.025, 0.04))
		car.position = Vector3(-5 if i == 0 else 5, 0, 6)
		cars.append(car)
	var cam := Camera3D.new()
	add_child(cam)
	cam.current = true
	cam.position = Vector3(0, 15, 27)
	cam.look_at(Vector3(0, 0, -8))
	var light := DirectionalLight3D.new()
	add_child(light)
	light.rotation_degrees = Vector3(-45, 25, 0)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := VBoxContainer.new()
	panel.position = Vector2(24, 24)
	layer.add_child(panel)
	var title := Label.new()
	title.text = "AOTO RACING LIVE"
	title.add_theme_font_size_override("font_size", 30)
	panel.add_child(title)
	status_label = Label.new()
	panel.add_child(status_label)
	var racing := Button.new()
	racing.text = "RACING"
	panel.add_child(racing)
	racing.pressed.connect(func(): mode = 0; elapsed = 0)
	var drift := Button.new()
	drift.text = "FUNK DRIFT"
	panel.add_child(drift)
	drift.pressed.connect(func(): mode = 1; elapsed = 0)
	var like := Button.new()
	like.text = "Curtir: NITRO"
	panel.add_child(like)
	like.pressed.connect(func(): nitro = minf(nitro + 2, 8))
	var comment := Button.new()
	comment.text = "Comentario: TURBO"
	panel.add_child(comment)
	comment.pressed.connect(func(): effect += 2)
	var gift := Button.new()
	gift.text = "Presente: EFEITO"
	panel.add_child(gift)
	gift.pressed.connect(func(): nitro = 8; effect += 4)
	var note := Label.new()
	note.text = "Simulacao offline - sem conexao TikTok"
	panel.add_child(note)

func _process(delta: float) -> void:
	elapsed += delta
	nitro = maxf(0, nitro - delta)
	effect = maxf(0, effect - delta)
	for i in range(cars.size()):
		var car := cars[i]
		var speed := 10.0 + float(i) + nitro * (1.0 if i == 0 else 0.25)
		car.position.z = 6.0 - fmod(elapsed * speed, 155.0)
		if mode == 1:
			car.position.x = (-5.0 if i == 0 else 5.0) + sin(elapsed * 1.8 + float(i) * 2) * (2 + effect)
			car.rotation.y = sin(elapsed * 1.8 + float(i) * 2) * 0.4
		else:
			car.position.x = -5 if i == 0 else 5
			car.rotation.y = 0
	status_label.text = ("RACING" if mode == 0 else "FUNK DRIFT") + " | NITRO: %d%%" % int(nitro * 12.5)
