extends "res://abilities/Ability.gd"

func _ready():
	can_damage = true

func use():
	var projectile = load("res://abilities/Projectile.tscn").instance()
	projectile.global_position = get_parent().get_node("HandPosition").global_position
	projectile.velocity = Vector2(400, 0)
	get_node("/root").add_child(projectile)