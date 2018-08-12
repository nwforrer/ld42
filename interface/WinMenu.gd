extends Control

func display():
	show()
	$CenterContainer/VBoxContainer/PlayAgain.grab_focus()

func _on_PlayAgain_pressed():
	hide()
	get_parent().get_parent().reset()
	get_tree().paused = false


func _on_Quit_pressed():
	get_tree().change_scene('res://interface/QuitPage.tscn')


func _on_PlayAgain_mouse_entered():
	$CenterContainer/VBoxContainer/PlayAgain.grab_focus()


func _on_Quit_mouse_entered():
	$CenterContainer/VBoxContainer/Quit.grab_focus()
