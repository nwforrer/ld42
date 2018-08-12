extends Node2D

signal hit_empty_space
signal map_complete
signal room_created

const MAP_DIR = "res://maps"

const EMPTY_TILE_INDEX = 1
const WALL_TILE_INDICES = [2,3]

var available_room_files = []
var placed_rooms = []
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
	
	get_player_grid_pos()
	
	reset()

func _generate_room_order():
	pass

func reset():
	placed_rooms.clear()
	$Player.reset(Vector2(200, 200))
	
	for e in $EnemyHolder.get_children():
		e.queue_free()
	for m in $MapHolder.get_children():
		m.queue_free()
	
	spawn_room(0)
	spawn_enemies()

func _process(delta):
	var tile_map = $MapHolder/Map/TileMap
	if not tile_map:
		return
		
	var player_coord = tile_map.world_to_map($Player.global_position)
	var tile_index = tile_map.get_cellv(player_coord)
	if tile_index == EMPTY_TILE_INDEX and $Player.state != $Player.STATES.ACTION and abs($Player.height) < 1:
		emit_signal('hit_empty_space')

func spawn_enemies():
	if not $MapHolder/Map:
		return
	var spawn_list = $MapHolder/Map/EnemySpawns
	print('spawn_list:' + str(spawn_list))
	var enemy = load('res://entities/enemies/Enemy.tscn')
	for e in spawn_list.get_children():
		print('spawn:' + str(e) + ' at ' + str(e.global_position))
		var new_enemy = enemy.instance()
		new_enemy.global_position = e.global_position
		new_enemy.connect('enemy_leap', self, '_on_Enemy_leap')
		$EnemyHolder.add_child(new_enemy)

func spawn_room(base_seed):
	print("adding room")
	print(available_room_files.size())
	
	rand_seed(base_seed)
	var rand_index = randi()%available_room_files.size()
	print(rand_index)
	var map_file_name = available_room_files[rand_index]
	print(map_file_name)
	
	var next_room = load(MAP_DIR + "/" + map_file_name).instance()
	next_room.name = "Map"
	$MapHolder.add_child(next_room)
	
	if $MapHolder/Map/Door:
		connect('map_complete', $MapHolder/Map/Door, '_on_Map_complete')
	if $MapHolder/Map/ExitArea:
		$MapHolder/Map/ExitArea.connect('area_entered', self, '_on_ExitArea_entered')
	
	placed_rooms.append(next_room)
	
	current_room = next_room
	
	emit_signal('room_created', $MapHolder/Map)
	
func get_player_grid_pos():
	var window_size = OS.get_window_size()
	var pos = $Player.position
	var x = floor(pos.x / window_size.x)
	var y = floor(pos.y / window_size.y)
	
	return Vector2(x, y)

func _on_Player_action_used(world_position):
	var tile_map = $MapHolder/Map/TileMap
	if not tile_map:
		return
	var tile_coord = tile_map.world_to_map(world_position)
	print(tile_map.get_cellv(tile_coord))
	tile_map.set_cell(tile_coord.x, tile_coord.y, EMPTY_TILE_INDEX)

func _on_Ability_spawn_projectile(projectile):
	projectile.connect('projectile_collision', self, '_on_Projectile_collision')
	get_node("/root").add_child(projectile)

func _on_Projectile_collision(projectile, collider):
	if $EnemyHolder.get_child_count() == 1:
		print('game won')
		emit_signal('map_complete')
		
	projectile.queue_free()
	collider.queue_free()

func _on_Enemy_leap(leap_pos):
	var tile_map = $MapHolder/Map/TileMap
	var tile_coord = tile_map.world_to_map(leap_pos)
	var tile_index = tile_map.get_cellv(tile_coord)
	if not tile_index in WALL_TILE_INDICES:
		tile_map.set_cellv(tile_coord, EMPTY_TILE_INDEX)

func _on_ExitArea_entered(area):
	print('next level...')

func _on_Player_died():
	print('game over')
	reset()


func _on_Area2D_area_entered(area):
	print('foo')


func _on_StaticBody2D_body_entered(body):
	print('bar')
