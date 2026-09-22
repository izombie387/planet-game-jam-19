extends Node

enum Sound{ TICK, }

const MUSIC := preload("res://audio/music/mix and master.mp3")
const SFX : Dictionary[Sound, AudioStream] = {
	Sound.TICK: preload("res://audio/sfx/tick.wav"),
}

var sfx_player := AudioStreamPlayer.new()
var music_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(sfx_player)
	sfx_player.max_polyphony = 1
	add_child(music_player)
	music_player.max_polyphony = 1
	music_player.stream = MUSIC
	
func start_music() -> void:
	music_player.play()
	
func play(sound: Sound) -> void:
	sfx_player.stream = SFX[sound]
	sfx_player.play()
		
		
		
