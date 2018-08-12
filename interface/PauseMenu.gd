extends Control


func display():
	show()
	$CenterContainer/VBoxContainer/Continue.grab_focus()

func _on_Continue_pressed():
	hide()
	get_tree().paused = false

func _on_Quit_pressed():
	get_tree().change_scene('res://interface/QuitPage.tscn')

func _on_Continue_mouse_entered():
	$CenterContainer/VBoxContainer/Continue.grab_focus()

func _on_Quit_mouse_entered():
	$CenterContainer/VBoxContainer/Quit.grab_focus()


func _on_Restart_pressed():
	hide()
	get_parent().get_parent().reset()
	get_tree().paused = false


func _on_Restart_mouse_entered():
	$CenterContainer/VBoxContainer/Restart.grab_focus()
