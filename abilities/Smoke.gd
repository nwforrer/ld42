extends Particles2D

func _ready():
	$Timer.start()
	emitting = true


func _on_Timer_timeout():
	queue_free()