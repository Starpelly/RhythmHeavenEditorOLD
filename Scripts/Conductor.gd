extends AudioStreamPlayer

export var bpm = 177.5
export var measures := 4

var song_position = 0
var song_position_in_beats = 1
var song_position_in_fourbeats = 1
var sec_per_beat = 60.0 / bpm
var sec_per_fbeat = 15.0 / bpm
var last_reported_beat = 0
var last_reported_fourthbeat = 0
var beats_before_start = 0
var fbeats_before_start = 0
var measure = 1

var current_beat = 0
var current_fourthbeat = 0

var closest = 0
var time_off_beat = 0

var beats_on_beat = bpm * 2

var interval = 30000 #samples
var interval_sec = 60.0/bpm

signal beat(position)
signal forthbeat(position)
#signal measure(position)

var beat_has_happened
var time_begin
var time_delay

var metronomeEnabled = false

func _ready():
	sec_per_beat = 60.0 / bpm
	sec_per_fbeat = 15.0 / bpm
	interval = interval_sec*stream.mix_rate
	#time_begin = OS.get_ticks_usec()
	#time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	#play()
	if stream.stereo: interval = interval*4

func _process(_delta):
	
	bpm = bpm
	sec_per_beat = 60.0 / bpm
	
	if playing:
		#var time = 0.0
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		#song_position = (OS.get_ticks_usec() - time_begin) / 1000000.0
		#song_position -= time_delay
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		song_position_in_fourbeats = int(floor(song_position / sec_per_fbeat)) + beats_before_start
		_report_beat()
	if Input.is_action_just_pressed("ui_up"):
		print(song_position_in_beats)

func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if measure > measures:
			measure = 1
		emit_signal("beat", song_position_in_beats)
		if metronomeEnabled == true:
			$Metronome.play()
		#emit_signal("measure", measure)
		current_beat = current_beat + 1
		last_reported_beat = song_position_in_beats
		#print(current_beat)
		measure += 1
	elif last_reported_fourthbeat < song_position_in_fourbeats:
		emit_signal("forthbeat", song_position_in_fourbeats)
		#emit_signal("measure", measure)
		current_fourthbeat = current_fourthbeat + 1
		last_reported_fourthbeat = song_position_in_fourbeats
		#print("Current Fourth Beat: ", current_fourthbeat)
		measure += 1
		
func play_with_beat_offset(num):
	beats_before_start = num
	fbeats_before_start = num
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()
	
func closest_beat(nth):
	print("nsdds")
	closest = int(round((song_position / sec_per_beat) / nth) * nth)
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)
	
func play_from_beat(beat, _offset):
	print("assaasasn")
	play()
	seek(beat * sec_per_beat)
	#beats_before_start = offset
	#fbeats_before_start = offset
	current_fourthbeat = beat
	
	measure = beat % measures

func _on_StartTimer_timeout():
	print("assaasas")
	song_position_in_beats += 1
	song_position_in_fourbeats += 1
	if song_position_in_beats < beats_before_start - 1:
		$StartTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() +
														AudioServer.get_output_latency())
		$StartTimer.start()
	else:
		play()
		$StartTimer.stop()
	_report_beat()
