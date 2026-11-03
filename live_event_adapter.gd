extends Node
## Future authorized live-event adapter. No TikTok credentials or scraping.
## For now, consume local JSON events from user://aoto_events.json.
signal interaction(kind: String)
var enabled := false
var elapsed := 0.0
const PATH := "user://aoto_events.json"
const ALLOWED := ["like", "comment", "gift"]
const MAX_EVENTS := 12

func _process(delta: float) -> void:
	if not enabled:
		return
	elapsed += delta
	if elapsed < 1.0:
		return
	elapsed = 0.0
	if not FileAccess.file_exists(PATH):
		return
	var file := FileAccess.open(PATH, FileAccess.READ)
	if file == null:
		return
	var raw := file.get_as_text()
	file.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(PATH))
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Array):
		return
	var count := 0
	for entry in parsed:
		if count >= MAX_EVENTS:
			break
		if entry is Dictionary:
			var kind := str(entry.get("type", ""))
			if kind in ALLOWED:
				interaction.emit(kind)
				count += 1
