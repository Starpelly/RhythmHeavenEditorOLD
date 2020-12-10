extends Control

onready var Conductor = $Conductor

onready var Timeline = $TimelineBase
onready var LayersBase = $TimelineBase/LayersBase
onready var SongTimeBase = $TimelineBase/SongTimeBase
onready var TimelineMenuBase = $TimelineBase/TimelineMenuBase

onready var songPosText = $"TimelineBase/SongTimeBase/Song Position"
onready var currentTimeMarker = $TimelineBase/SongTimeBase/CurrentTimeMarker
onready var timelineScrollBar = $TimelineBase/SongTimeBase/ScrollBar
onready var BackBtnColorRect3 = $TimelineBase/TimelineMenuBase/BackButtons/ColorRect3

var metronomeSND = false

var isSongPlaying = false
var hasPlayed = false

func _ready():
	timelineScrollBar.max_value = Conductor.stream.get_length()
	pass

var vector
func _process(_delta):
	Conductor.bpm = $SettingsBox/BPMBox.value
	
	currentSongPos()
	onVolumeChange()
	
	if metronomeSND == true:
		Conductor.metronomeEnabled = true
		#BackBtnColorRect3.color = BackBtnColorRect3.color.linear_interpolate(Color(0.290196, 0.54902, 0.776471), 0.2)
	else:
		#BackBtnColorRect3.color = BackBtnColorRect3.color.linear_interpolate(Color(0.305882, 0.305882, 0.305882), 0.4)
		Conductor.metronomeEnabled = false
	
	if isSettingsMenuPoppedOut == true:
		$SettingsBox.rect_position = $SettingsBox.rect_position.linear_interpolate(Vector2(0, 0), 0.2)
	else:
		$SettingsBox.rect_position = $SettingsBox.rect_position.linear_interpolate(Vector2(-434.38, 0), 0.35)
	
	initMusicTimeline()
	
func _input(event):
	if event is InputEventMouseMotion:
		$TimelineBase/TimelineMenuBase/MousePos.text = str("Mouse Pos: \n", "x(", event.position.x, ") ",
																			"y(", event.position.y, ")")

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
		#currentTimeMarker.position = Vector2(150 + Conductor.song_position, 115.159)
		#currentTimeMarker.position = currentTimeMarker.position.linear_interpolate(Vector2(150 + Conductor.song_position, 115.159), 0.3)
		currentTimeMarker.position = currentTimeMarker.position.linear_interpolate(Vector2(1269.118, 115.159), 0.1)
	if isSongPlaying == false:
		if hasPlayed == true:
			timelineScrollBar.value = Conductor.song_position
			hasPlayed = false
		Conductor.song_position = timelineScrollBar.value

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

func onPlayBTNPressed():
	isPlayBtnPressed = isPlayBtnPressed + 1
	isSongPlaying = true
	
	if isPlayBtnPressed <= 1:
		hasPlayed = true
		Conductor.play(Conductor.song_position)
		isSongPlaying = true
		$TimelineBase/TimelineMenuBase/Play.texture_normal = preload("res://Sprites/editor_pausebutton.png")
		#$TimelineBase/TimelineMenuBase/Play.text = "Stop"
	elif isPlayBtnPressed >= 2:
		isSongPlaying = false
		Conductor.stop()
		#$TimelineBase/TimelineMenuBase/Play.text = "Play"
		$TimelineBase/TimelineMenuBase/Play.texture_normal = preload("res://Sprites/editor_playbutton.png")
		isPlayBtnPressed = 0
	pass
	

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
		timelineScrollBar.max_value = Conductor.stream.get_length()
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


func _on_Help_pressed():
	$TopButtons/HelpPopupDialog.popup()
	pass
