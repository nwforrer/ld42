extends KinematicBody2D

signal projectile_collision

var velocity = Vector2()

func _ready():
	$LifeTimer.start()

func _physics_process(delta):
	var collision_info = move_and_collide(velocity*delta)
	if collision_info:
		var collider = collision_info.collider
		emit_signal('projectile_collision', self, collider)

func _on_LifeTimer_timeout():
	queue_free()
