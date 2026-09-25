extends Node

enum Sound{ 
	TICK, UPGRADE, EXPLOSION, CLICK,
}

const MUSIC := preload("res://audio/ogg/Cavern Calamity.ogg")
const EVIL_MUSIC := preload("res://audio/ogg/Evil.ogg")
const SFX : Dictionary[Sound, AudioStream] = {
	Sound.TICK: preload("res://audio/sfx/tick.wav"),
	Sound.UPGRADE: preload("res://audio/ogg/Upgrade.ogg"),
	Sound.CLICK: preload("res://audio/ogg/Menu_Click.ogg"),
	Sound.EXPLOSION: preload("res://audio/ogg/Explosion.ogg"),
}

var sfx_player := AudioStreamPlayer.new()
var music_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(sfx_player)
	sfx_player.max_polyphony = 1
	
	add_child(music_player)
	var sync := AudioStreamSynchronized.new()
	sync.set_sync_stream(0, MUSIC)
	sync.set_sync_stream(1, EVIL_MUSIC)
	sync.stream_count = 2
	music_player.stream = sync
	
func get_sync() -> AudioStreamSynchronized:
	return music_player.stream
	
func start_music() -> void:
	var s := get_sync()
	if s.get_sync_stream_volume(1) == -80.0:
		s.set_sync_stream_volume(1, 0.0)
	else:
		s.set_sync_stream_volume(1, -80.0)
	music_player.play()
	
func play(sound: Sound) -> void:
	if sound not in SFX:
		return
	sfx_player.stream = SFX[sound]
	sfx_player.play()
		
		
