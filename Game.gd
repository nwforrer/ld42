extends Node2D

signal hit_empty_space

const MAP_DIR = "res://maps"

const EMPTY_TILE_INDEX = 1

var available_room_files = []
var current_room

func _ready():
	var dir = Directory.new()
	dir.open(MAP_DIR)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			print(file)
			available_room_files.append(file)
	dir.list_dir_end()
	
	$Player/FireSpellAbility.connect('spawn_projectile', self, '_on_Ability_spawn_projectile')
	
	reset()

func reset():
	$MapHolder.remove_child(get_node("MapHolder/Map"))
	$Player.reset(Vector2(200, 200))
	
	for e in $EnemyHolder.get_children():
		e.queue_free()
	
	spawn_room()
	spawn_enemies()

func _process(delta):
	var tile_map = $MapHolder/Map/TileMap
	var player_coord = tile_map.world_to_map($Player.global_position)
	var tile_index = tile_map.get_cellv(player_coord)
	if tile_index == EMPTY_TILE_INDEX and $Player.state != $Player.STATES.ACTION and abs($Player.height) < 1:
		emit_signal('hit_empty_space')

func spawn_enemies():
	var spawn_list = $MapHolder/Map/EnemySpawns
	print('spawn_list:' + str(spawn_list))
	var enemy = load('res://entities/enemies/Enemy.tscn')
	for e in spawn_list.get_children():
		print('spawn:' + str(e) + ' at ' + str(e.global_position))
		var new_enemy = enemy.instance()
		new_enemy.global_position = e.global_position
		$EnemyHolder.add_child(new_enemy)

func spawn_room():
	print("adding room")
	print(available_room_files.size())
	
	rand_seed(1)
	var rand_index = randi()%available_room_files.size()
	print(rand_index)
	var map_file_name = available_room_files[rand_index]
	print(map_file_name)
	
	var next_room = load(MAP_DIR + "/" + map_file_name).instance()
	next_room.name = "Map"
	$MapHolder.add_child(next_room)
	
	current_room = next_room

func _on_Player_action_used(world_position):
	var tile_map = $MapHolder/Map/TileMap
	var tile_coord = tile_map.world_to_map(world_position)
	print(tile_map.get_cellv(tile_coord))
	tile_map.set_cell(tile_coord.x, tile_coord.y, EMPTY_TILE_INDEX)

func _on_Ability_spawn_projectile(projectile):
	projectile.connect('projectile_collision', self, '_on_Projectile_collision')
	get_node("/root").add_child(projectile)

func _on_Projectile_collision(projectile, collider):
	projectile.queue_free()
	collider.queue_free()

func _on_Player_died():
	print('game over')
	reset()
