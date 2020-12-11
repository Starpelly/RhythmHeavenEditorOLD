extends Node2D

onready var anim_player = $AnimationPlayer

func _ready():
	anim_player.set_speed_scale(0.8)
	pass
	
func _process(delta):
	pass
func bop(bop):
	if bop == true:
		anim_player.play("ClappyTrioBop")
		bop = false
