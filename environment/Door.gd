extends Node2D

func _ready():
	$Closed.visible = true
	$Closed/CollisionShape2D.disabled = false
	$Open.visible = false
	$Open/CollisionShape2D.disabled = true
	
	$Open.connect('area_entered', self, '_on_Door_exited')
	
func _on_Map_complete():
	$Closed.visible = false
	$Closed/CollisionShape2D.disabled = true
	$Open.visible = true
	$Open/CollisionShape2D.disabled = false
	
func _on_Door_exited():
	print('testing testing')

func _on_Open_area_entered(area):
	print('testing testing 2')
