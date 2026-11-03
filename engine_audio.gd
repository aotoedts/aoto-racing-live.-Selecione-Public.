extends Node
## Lightweight procedural motor sound, no external copyrighted recordings.
const RATE := 22050
var player: AudioStreamPlayer
var stream: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var engine_speed := 0.0
var enabled := false
var phase := 0.0
var time := 0.0

func _ready() -> void:
	stream = AudioStreamGenerator.new()
	stream.mix_rate = RATE
	stream.buffer_length = 0.3
	player = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = -20
	add_child(player)
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func set_engine(active: bool, speed: float) -> void:
	enabled = active
	engine_speed = speed

func _process(_delta: float) -> void:
	if playback == null:
		return
	var frames := mini(playback.get_frames_available(), 4096)
	for i in range(frames):
		var freq := 65.0 + engine_speed * 3.0
		phase += TAU * freq / RATE
		var sound := (sin(phase) + sin(phase * 2.02) * 0.22) * 0.12 if enabled else 0.0
		playback.push_frame(Vector2(sound, sound))
		time += 1.0 / RATE
