extends Control

var scene_path_to_load

func _ready():
	#OS.set_window_fullscreen(true)
	$Menu/CenterRow/Buttons/NewGameButton.grab_focus()
	for button in $Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])

func _on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)


func _on_NewGameButton_mouse_entered():
	$Menu/CenterRow/Buttons/NewGameButton.grab_focus()


func _on_HelpButton_mouse_entered():
	$Menu/CenterRow/Buttons/HelpButton.grab_focus()


func _on_QuitButton_mouse_entered():
	$Menu/CenterRow/Buttons/QuitButton.grab_focus()
