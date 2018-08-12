extends "res://abilities/Ability.gd"

signal spawn_projectile

const PROJECTILE_SPEED = 400

func _ready():
	can_damage = true

func use(facing):
	var projectile = load("res://abilities/Projectile.tscn").instance()
	projectile.global_position = get_parent().get_node("Pivot/HandPosition").global_position
	projectile.velocity = facing.normalized() * PROJECTILE_SPEED
	emit_signal('spawn_projectile', projectile)