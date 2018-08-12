extends Control

func _ready():
	pass


func _on_Continue_pressed():
	hide()
	get_tree().paused = false


func _on_Quit_pressed():
	get_tree().change_scene('res://interface/QuitPage.tscn')
