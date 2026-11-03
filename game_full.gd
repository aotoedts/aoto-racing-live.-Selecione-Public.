extends Node3D
## AOTO Racing Live - offline-first interactive racing showcase for Android.
## TikTok inputs are simulated locally. No unofficial connection is used.

const SAVE_PATH := "user://aoto_settings.cfg"
const TRACK_LENGTH := 260.0
const LAPS := 3
const COLORS := [Color("#ff365e"), Color("#12d8ff"), Color("#f4cc39"), Color("#b87bff")]
var mode := 0 # 0 racing, 1 funk drift
var running := false
var paused := false
var elapsed := 0.0
var countdown := 3.0
var nitro := 0.0
var hype := 0.0
var likes := 0
var comments := 0
var gifts := 0
var speed_multiplier := 1.0
var quality_low := true
var music_enabled := false
var selected_car := 0
var laps := [0, 0]
var distance := [0.0, 0.0]
var vehicles: Array[Node3D] = []
var wheels: Array[Array] = []
var camera: Camera3D
var ui: Control
var menu: PanelContainer
var hud: PanelContainer
var settings_panel: PanelContainer
var status: Label
var score: Label
var stats: Label
var countdown_label: Label
var result_label: Label
var glow_nodes: Array[MeshInstance3D] = []
var particles: Array[MeshInstance3D] = []
var track_mesh: Node3D
var rng := RandomNumberGenerator.new()
var arcade_audio: Node
var smoke: Node3D
var smoke_timer := 0.0

func _ready() -> void:
	rng.randomize()
	_load_settings()
	_build_world()
	_build_interface()
	arcade_audio = load("res://audio_arcade.gd").new()
	add_child(arcade_audio)
	smoke = load("res://drift_smoke.gd").new()
	add_child(smoke)
	_show_menu()

func _material(color: Color, emissive := false) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.metallic = 0.3
	m.roughness = 0.35
	if emissive:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = 1.8
	return m

func _cube(parent: Node3D, size: Vector3, pos: Vector3, color: Color, emissive := false) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	n.mesh = mesh
	n.position = pos
	n.material_override = _material(color, emissive)
	parent.add_child(n)
	return n

func _build_world() -> void:
	track_mesh = Node3D.new()
	add_child(track_mesh)
	_cube(track_mesh, Vector3(40, 0.3, 360), Vector3(0, -0.3, -110), Color("#111321"))
	for i in range(60):
		var z := 45.0 - float(i) * 6.0
		_cube(track_mesh, Vector3(0.25, 0.03, 3.0), Vector3(0, -0.12, z), Color("#a6f5ff"), true)
		for side in [-1, 1]:
			var s := float(side)
			_cube(track_mesh, Vector3(0.4, 0.45, 5.8), Vector3(s * 17, 0.1, z), Color("#8428ce"), true)
			if i % 3 == 0:
				var h := 7.0 + float(i % 7) * 2.0
				_cube(track_mesh, Vector3(5, h, 5), Vector3(s * 24, h * 0.5 - 0.1, z), Color("#20253b"))
				_cube(track_mesh, Vector3(5.1, 0.25, 5.1), Vector3(s * 24, h - 0.1, z), Color("#23c9f0"), true)
	for i in range(2):
		var vehicle := Node3D.new()
		add_child(vehicle)
		var paint := COLORS[i]
		_cube(vehicle, Vector3(2.6, 0.6, 5.0), Vector3(0, 0.85, 0), paint)
		_cube(vehicle, Vector3(2.05, 0.7, 2.2), Vector3(0, 1.48, -0.45), Color("#131c30"))
		_cube(vehicle, Vector3(2.8, 0.12, 0.55), Vector3(0, 1.32, 2.1), paint)
		_cube(vehicle, Vector3(1.8, 0.12, 0.2), Vector3(0, 1.65, 2.1), paint)
		_cube(vehicle, Vector3(2.2, 0.18, 0.14), Vector3(0, 0.86, 2.55), Color("#ff243c"), true)
		_cube(vehicle, Vector3(2.2, 0.18, 0.14), Vector3(0, 0.86, -2.55), Color("#ddfaff"), true)
		var car_wheels: Array[MeshInstance3D] = []
		for x in [-1.3, 1.3]:
			for z in [-1.5, 1.5]:
				var wheel := _cube(vehicle, Vector3(0.4, 0.8, 0.85), Vector3(x, 0.48, z), Color("#090a0f"))
				car_wheels.append(wheel)
		wheels.append(car_wheels)
		vehicles.append(vehicle)
	camera = Camera3D.new()
	add_child(camera)
	camera.current = true
	camera.fov = 67
	camera.position = Vector3(0, 11, 23)
	camera.look_at(Vector3(0, 0, -10))
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-55, 20, 0)
	sun.light_energy = 0.65
	var env := WorldEnvironment.new()
	add_child(env)
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#090c1b")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#65708e")
	environment.ambient_light_energy = 0.7
	env.environment = environment

func _button(label: String, parent: Node, action: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size = Vector2(210, 51)
	b.add_theme_font_size_override("font_size", 19)
	parent.add_child(b)
	b.pressed.connect(action)
	return b

func _label(text_value: String, parent: Node, size := 22) -> Label:
	var l := Label.new()
	l.text = text_value
	l.add_theme_font_size_override("font_size", size)
	parent.add_child(l)
	return l

func _panel(root: Control, left: float, top: float) -> PanelContainer:
	var p := PanelContainer.new()
	p.position = Vector2(left, top)
	root.add_child(p)
	return p

func _build_interface() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	ui = Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(ui)
	menu = _panel(ui, 25, 25)
	var menu_col := VBoxContainer.new()
	menu.add_child(menu_col)
	_label("AOTO RACING LIVE", menu_col, 34)
	_label("Corridas 3D + Funk Drift", menu_col, 20)
	_button("INICIAR RACING", menu_col, func(): _start(0))
	_button("INICIAR FUNK DRIFT", menu_col, func(): _start(1))
	_button("CONFIGURACOES", menu_col, _show_settings)
	_label("Protótipo offline | Android", menu_col, 16)
	hud = _panel(ui, 22, 20)
	var hud_col := VBoxContainer.new()
	hud.add_child(hud_col)
	status = _label("", hud_col, 24)
	score = _label("", hud_col, 20)
	stats = _label("", hud_col, 17)
	var actions := HBoxContainer.new()
	hud_col.add_child(actions)
	_button("CURTIDA + NITRO", actions, func(): _event("like"))
	_button("COMENTARIO + TURBO", actions, func(): _event("comment"))
	_button("PRESENTE + EFEITO", actions, func(): _event("gift"))
	var controls := HBoxContainer.new()
	hud_col.add_child(controls)
	_button("PAUSAR / VOLTAR", controls, _toggle_pause)
	_button("MENU", controls, _show_menu)
	countdown_label = _label("", hud_col, 28)
	result_label = _label("", hud_col, 25)
	settings_panel = _panel(ui, 25, 25)
	var settings_col := VBoxContainer.new()
	settings_panel.add_child(settings_col)
	_label("CONFIGURACOES", settings_col, 30)
	_button("QUALIDADE: ALTERNAR", settings_col, func(): quality_low = not quality_low; _save_settings())
	_button("VELOCIDADE: ALTERNAR", settings_col, func(): speed_multiplier = 1.25 if speed_multiplier == 1.0 else 1.0; _save_settings())
	_button("SOM ORIGINAL: LIGAR / DESLIGAR", settings_col, func(): music_enabled = not music_enabled; _save_settings())
	_button("VOLTAR", settings_col, _show_menu)

func _show_menu() -> void:
	running = false
	paused = false
	menu.visible = true
	hud.visible = false
	settings_panel.visible = false
	if arcade_audio != null:
		arcade_audio.set_music(false, mode == 1)

func _show_settings() -> void:
	menu.visible = false
	hud.visible = false
	settings_panel.visible = true

func _start(new_mode: int) -> void:
	mode = new_mode
	running = true
	paused = false
	elapsed = 0
	countdown = 3
	nitro = 0
	hype = 0
	likes = 0
	comments = 0
	gifts = 0
	laps = [0, 0]
	distance = [0.0, 0.0]
	result_label.text = ""
	menu.visible = false
	settings_panel.visible = false
	hud.visible = true
	arcade_audio.set_music(music_enabled, mode == 1)

func _toggle_pause() -> void:
	if running:
		paused = not paused
		arcade_audio.set_music(music_enabled and not paused, mode == 1)

func _event(kind: String) -> void:
	if not running or paused or countdown > 0:
		return
	match kind:
		"like":
			likes += 1
			nitro = minf(100, nitro + 15)
		"comment":
			comments += 1
			hype = minf(100, hype + 20)
		"gift":
			gifts += 1
			nitro = minf(100, nitro + 40)
			hype = minf(100, hype + 45)

func _process(delta: float) -> void:
	if not running or paused:
		return
	if countdown > 0:
		countdown -= delta
		countdown_label.text = "LARGADA EM: %d" % maxi(1, ceili(countdown)) if countdown > 0 else "VAI!"
		return
	countdown_label.text = ""
	elapsed += delta
	smoke_timer += delta
	if mode == 1 and smoke_timer >= (0.15 if quality_low else 0.08):
		smoke_timer = 0.0
		for vehicle in vehicles:
			smoke.emit_at(vehicle.global_position + Vector3(0, 0.4, 1.7))
	nitro = maxf(0, nitro - delta * 7)
	hype = maxf(0, hype - delta * 5)
	for i in range(2):
		var boost := (nitro * 0.13 + hype * 0.07) if i == 0 else 0.0
		var speed := (24.0 + float(i) * 0.8 + boost) * speed_multiplier
		distance[i] += delta * speed
		laps[i] = mini(LAPS, int(distance[i] / TRACK_LENGTH))
		var progress := fmod(distance[i], TRACK_LENGTH)
		var car := vehicles[i]
		car.position.z = 18.0 - progress * 0.72
		if mode == 1:
			car.position.x = (-5.5 if i == 0 else 5.5) + sin(elapsed * 1.4 + float(i) * 2.0) * 2.5
			car.rotation.y = sin(elapsed * 1.4 + float(i) * 2.0) * 0.36
		else:
			car.position.x = -5.5 if i == 0 else 5.5
			car.rotation.y = 0
		for wheel in wheels[i]:
			wheel.rotation.x += delta * speed * 0.45
	status.text = ("RACING LIVE" if mode == 0 else "FUNK DRIFT LIVE") + (" | PAUSADO" if paused else "")
	score.text = "Vermelho: %d/%d voltas | Azul: %d/%d voltas" % [laps[0], LAPS, laps[1], LAPS]
	stats.text = "Nitro %d%% | Hype %d%% | Curtidas %d | Comentarios %d | Presentes %d" % [int(nitro), int(hype), likes, comments, gifts]
	if laps[0] >= LAPS or laps[1] >= LAPS:
		running = false
		arcade_audio.set_music(false, mode == 1)
		result_label.text = "VENCEDOR: " + ("VERMELHO" if distance[0] >= distance[1] else "AZUL") + " | MENU para reiniciar"

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("graphics", "low", quality_low)
	cfg.set_value("audio", "enabled", music_enabled)
	cfg.set_value("gameplay", "speed", speed_multiplier)
	cfg.save(SAVE_PATH)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		quality_low = bool(cfg.get_value("graphics", "low", true))
		music_enabled = bool(cfg.get_value("audio", "enabled", false))
		speed_multiplier = float(cfg.get_value("gameplay", "speed", 1.0))
