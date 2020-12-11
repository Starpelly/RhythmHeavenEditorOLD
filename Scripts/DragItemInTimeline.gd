extends Area2D

var previous_mouse_position = Vector2()
var is_dragging = false

func _ready():
	
	pass


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("ui_touch"):
		print(event)
		get_tree().set_input_as_handled()
		previous_mouse_position = event.position
		is_dragging = true
	pass
	
func _input(event):
	if not is_dragging:
		return
	
	if event.is_action_released("ui_touch"):
		previous_mouse_position = Vector2()
		is_dragging = false
		
	if is_dragging and event is InputEventMouseMotion:
		position += event.position - previous_mouse_position
		previous_mouse_position = event.position
