extends Control

onready var Conductor = $Conductor

onready var Timeline = $TimelineBase
onready var SongTimeBase = $TimelineBase/SongTimeBase
onready var TimelineMenuBase = $TimelineBase/TimelineMenuBase

onready var songPosText = $"TimelineBase/SongTimeBase/Song Position"
onready var currentTimeMarker = $TimelineBase/SongTimeBase/CurrentTimeMarker
onready var timelineScrollBar = $TimelineBase/SongTimeBase/ScrollBar
onready var BackBtnColorRect3 = $TimelineBase/TimelineMenuBase/BackButtons/ColorRect3

onready var GamePreviewViewport = $ViewportContainer/Viewport
onready var GamePreview = $ViewportContainer/Viewport/Node2D

var metronomeSND = false

var isSongPlaying = false
var hasPlayed = false

func _ready():
	$TimelineBase/SongPathText.text = str(Conductor.stream)
	$SettingsBox/BPMBox.value = Conductor.bpm
	timelineScrollBar.max_value = Conductor.stream.get_length()
	pass

var vector
func _process(_delta):
	Conductor.bpm = $SettingsBox/BPMBox.value
	
	currentSongPos()
	onVolumeChange()
	
	if metronomeSND == true:
		Conductor.metronomeEnabled = true
	else:
		Conductor.metronomeEnabled = false
	
	if isSettingsMenuPoppedOut == true:
		$SettingsBox.rect_position = $SettingsBox.rect_position.linear_interpolate(Vector2(0, 0), 0.2)
	else:
		$SettingsBox.rect_position = $SettingsBox.rect_position.linear_interpolate(Vector2(-434.38, 0), 0.35)
	
	initMusicTimeline()
	
func _on_Conductor_beat(position):
	GamePreview.bop(true)
	pass


func _input(event):
	if event is InputEventMouseMotion:
		$TimelineBase/TimelineMenuBase/MousePos.text = str("Mouse Pos: \n", "x(", event.position.x, ") ",
																			"y(", event.position.y, ")")
	if Input.is_action_just_pressed("playpause"):
		onPlayBTNPressed()
	if timelineScrollBar.value == timelineScrollBar.max_value && Input.is_action_just_pressed("playpause"):
		print("restart")
		restartSong()
	if Input.is_action_just_pressed("record"):
		_on_Record_pressed()
	if Input.is_action_just_pressed("metronome"):
		MetronomeButtonPressed()
	if Input.is_action_just_pressed("playtest"):
		print("playtest")
		
	if Input.is_action_pressed("fastforwardright"):
		timelineScrollBar.value += 1
		#yield(get_tree().create_timer(2.25),"timeout")
	if Input.is_action_pressed("fastforwardleft"):
		timelineScrollBar.value -= 1
		pass
	
	if Input.is_action_pressed("fastforwardbeat"):
		timelineScrollBar.value += Conductor.sec_per_beat
		pass

##SAVING---------------------------------------------------------------------------------------------------

func askToSave():
	$TopButtons/Save.modulate = Color(1, 0, 0)
	
func save():
	$TopButtons/Save.modulate = Color(1, 1, 1)
	
func _on_Save_pressed():
	save()
	pass
	
##---------------------------------------------------------------------------------------------------------

func initMusicTimeline():
	#REPLACE THIS!!!!!!!!!!!!
	if isSongPlaying == true:
		timelineScrollBar.value = Conductor.song_position
		Conductor.last_reported_beat = Conductor.song_position_in_beats #Fixes some bug for some reason
		currentTimeMarker.position = currentTimeMarker.position.linear_interpolate(Vector2(1269.118, 115.159), 0.1)
	if isSongPlaying == false:
		
		Conductor.song_position = timelineScrollBar.value

func restartSong():
	isSongPlaying = true
	isPlayBtnPressed += 1
	$TimelineBase/TimelineMenuBase/Play.texture_normal = preload("res://Sprites/Editor/editor_pausebutton.png")
	timelineScrollBar.value = 0
	Conductor.song_position = 0
	Conductor.play(Conductor.song_position)

func onPlayBTNPressed():
	isPlayBtnPressed += 1
	isSongPlaying = true
	
	if isPlayBtnPressed == 1:
		hasPlayed = true
		Conductor.play(Conductor.song_position)
		timelineScrollBar.value = Conductor.song_position
		isSongPlaying = true
		$TimelineBase/TimelineMenuBase/Play.texture_normal = preload("res://Sprites/Editor/editor_pausebutton.png")
	elif isPlayBtnPressed == 2:
		isSongPlaying = false
		Conductor.stop()
		$TimelineBase/TimelineMenuBase/Play.texture_normal = preload("res://Sprites/Editor/editor_playbutton.png")
		isPlayBtnPressed = 0
	pass

var isMetronomeBtnPressed = 0
func MetronomeButtonPressed():
	isMetronomeBtnPressed = isMetronomeBtnPressed + 1
	if isMetronomeBtnPressed <= 1:
		BackBtnColorRect3.color = Color(0.290196, 0.54902, 0.776471)
		metronomeSND = true
	elif isMetronomeBtnPressed >= 2:
		BackBtnColorRect3.color = Color(0.305882, 0.305882, 0.305882)
		metronomeSND = false
		isMetronomeBtnPressed = 0

var isPlayBtnPressed = 0


func currentSongPos():
	songPosText.text = str(timelineScrollBar.value)

var volumeischanged = false
func onVolumeChange():
	if volumeischanged == true:
		Conductor.volume_db = $TimelineBase/TimelineMenuBase/VolumeSlider.value
		$TimelineBase/TimelineMenuBase/VolumeSlider/Text.text = str("Volume: ", Conductor.volume_db)
		volumeischanged = false
	if $TimelineBase/TimelineMenuBase/VolumeSlider.value <= -65:
		Conductor.volume_db = -800
		$TimelineBase/TimelineMenuBase/VolumeSlider/Text.text = str("Volume: -infinity")
	
func onVolumeValueChanged():
	volumeischanged = true
	pass

func onResetVolBTNPressed():
	Conductor.volume_db = 0
	$TimelineBase/TimelineMenuBase/VolumeSlider/Text.text = str("Volume: ", Conductor.volume_db)
	$TimelineBase/TimelineMenuBase/VolumeSlider.value = 0
	volumeischanged = false


func onSelectSongPressed():
	$TopButtons/SelectSongDialogue.popup()
	pass


func onSelectSongDialogueFileSelected(path):
	Conductor.stream = load(path)
	$TimelineBase/SongPathText.text = str(path)
	initMusicTimeline()
	if Conductor.stream == null:
		$TimelineBase/SongPathText.text = str("Failed to load!")
	else:
		restartSong()
		timelineScrollBar.max_value = Conductor.stream.get_length()
	pass

func _on_Help_pressed():
	$TopButtons/HelpPopupDialog.popup()
	pass

var recordBtnPressed = 0
func _on_Record_pressed():
	recordBtnPressed += 1
	if recordBtnPressed <= 1:
		$TimelineBase/TimelineMenuBase/BackButtons/ColorRect2.color = Color(0.458824, 0.196078, 0.196078)
	elif recordBtnPressed >= 2:
		$TimelineBase/TimelineMenuBase/BackButtons/ColorRect2.color = Color(0.305882, 0.305882, 0.305882)
		recordBtnPressed = 0
	pass

var isSettingsBTNPressed = 0
var isSettingsMenuPoppedOut = false
func onSettingsPressed():
	isSettingsBTNPressed += 1
	if isSettingsBTNPressed <= 1:
		isSettingsMenuPoppedOut = true
		$SettingsBox.visible = true
	elif isSettingsBTNPressed >= 2:
		isSettingsMenuPoppedOut = false
		isSettingsBTNPressed = 0
	pass

func _on_BPMBox_value_changed(value):
	askToSave()
	pass
	
func showErrorText(stringtoshow, isvisible):
	if isvisible == true:
		$ErrorText.visible = true
	else:
		$ErrorText.visible = false
	$ErrorText.text = str(stringtoshow)
