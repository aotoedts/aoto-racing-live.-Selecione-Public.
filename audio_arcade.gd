extends Node
## Original synthesized arcade soundtrack and effects, no copyrighted samples.
const RATE := 22050
var player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var beat_time := 0.0
var running := false
var drift_mode := false
var volume := 0.16
var phase := 0.0
var kick_phase := 0.0
var snare_phase := 0.0

func _ready() -> void:
	player = AudioStreamPlayer.new()
	var stream := AudioStreamGenerator.new()
	stream.mix_rate = RATE
	stream.buffer_length = 0.35
	player.stream = stream
	player.volume_db = -10
	add_child(player)
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback
	set_process(true)

func set_music(enabled: bool, drift: bool) -> void:
	running = enabled
	drift_mode = drift

func _process(_delta: float) -> void:
	if playback == null:
		return
	var available := mini(playback.get_frames_available(), 4096)
	for i in range(available):
		var t := beat_time
		var bpm := 132.0 if drift_mode else 118.0
		var beats := t * bpm / 60.0
		var beat_frac := fposmod(beats, 1.0)
		var kick := exp(-beat_frac * 22.0) * sin(TAU * (62.0 - beat_frac * 25.0) * t)
		var snare_gate := 1.0 if int(floor(beats)) % 4 == 2 else 0.0
		var snare := snare_gate * exp(-beat_frac * 32.0) * sin(TAU * 180.0 * t)
		var hat := exp(-fposmod(beats * 2.0, 1.0) * 28.0) * sin(TAU * 4200.0 * t)
		var bass_freq := 55.0 if int(floor(beats / 4.0)) % 2 == 0 else 65.4
		phase += TAU * bass_freq / RATE
		var bass := sin(phase) * 0.38
		var sample := (kick * 0.5 + snare * 0.16 + hat * 0.04 + bass) * volume if running else 0.0
		playback.push_frame(Vector2(sample, sample))
		beat_time += 1.0 / RATE
