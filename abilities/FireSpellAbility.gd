extends "res://abilities/Ability.gd"

signal spawn_projectile

func _ready():
	can_damage = true

func use():
	var projectile = load("res://abilities/Projectile.tscn").instance()
	projectile.global_position = get_parent().get_node("HandPosition").global_position
	projectile.velocity = Vector2(400, 0)
	emit_signal('spawn_projectile', projectile)