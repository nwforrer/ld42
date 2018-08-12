extends Control

func _ready():
	pass


func _on_TryAgain_pressed():
	hide()
	get_parent().get_parent().reset()
	get_tree().paused = false


func _on_Quit_pressed():
	get_tree().change_scene('res://interface/QuitPage.tscn')
