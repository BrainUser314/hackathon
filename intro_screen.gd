extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()


func _on_start_btn_pressed():
	get_tree().change_scene_to_file("res://levels/frontlawn/frontlawn.tscn")