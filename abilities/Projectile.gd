extends KinematicBody2D

var velocity = Vector2()
var lifetime = 5 # in seconds

func _ready():
	$LifeTimer.start()

func _physics_process(delta):
	move_and_collide(velocity*delta)

func _on_LifeTimer_timeout():
	queue_free()
