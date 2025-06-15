extends AudioStreamPlayer

var audio_stream_player: AudioStreamPlayer

func _ready():
	audio_stream_player = AudioStreamPlayer.new()
	add_child(audio_stream_player)
	audio_stream_player.bus = "Music"
	audio_stream_player.autoplay = false

func play_bgm(stream: AudioStream) -> void:
	if audio_stream_player.stream != stream:
		audio_stream_player.stream = stream
	audio_stream_player.play()

func stop_bgm() -> void:
	audio_stream_player.stop()

func is_bgm_playing() -> bool:
	return audio_stream_player.playing
