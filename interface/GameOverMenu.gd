extends Control

func display():
	show()
	$CenterContainer/VBoxContainer/TryAgain.grab_focus()

func _on_TryAgain_pressed():
	hide()
	get_parent().get_parent().reset()
	get_tree().paused = false


func _on_Quit_pressed():
	get_tree().change_scene('res://interface/QuitPage.tscn')


func _on_TryAgain_mouse_entered():
	$CenterContainer/VBoxContainer/TryAgain.grab_focus()


func _on_Quit_mouse_entered():
	$CenterContainer/VBoxContainer/Quit.grab_focus()
