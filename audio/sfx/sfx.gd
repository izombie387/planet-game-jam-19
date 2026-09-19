extends Node

enum Sound{ TICK, }

const SFX : Dictionary[Sound, AudioStream] = {
	Sound.TICK: preload("res://audio/sfx/tick.wav")
}

var sfx_player := AudioStreamPlayer.new()

func _ready() -> void:
	add_child(sfx_player)
	sfx_player.max_polyphony = 1
	
func play(sound: Sound) -> void:
	sfx_player.stream = SFX[sound]
	sfx_player.play()
		
		
		
