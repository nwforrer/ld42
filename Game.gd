extends Node2D

signal hit_empty_space
signal map_complete
signal room_created

const MAP_DIR = "res://maps"

const GROUND_TILE_INDEX = 0
const EMPTY_TILE_INDEX = 1
const WALL_TILE_INDICES = [2,3]

var player_grid_pos = Vector2()
var cur_enemy_holder

var cell_size = Vector2()
var map_size = Vector2()

var available_room_files = []
var placed_rooms = []

func process_input():
	if Input.is_action_just_pressed('pause'):
		$Camera2D/PauseMenu.display()
		get_tree().paused = true

func _ready():
	$Player/FireSpellAbility.connect('spawn_projectile', self, '_on_Ability_spawn_projectile')
	
	$Camera2D/PauseMenu.hide()
	$Camera2D/GameOverMenu.hide()
	$Camera2D/WinMenu.hide()
	
	#rand_seed(0)
	randomize()
	
	reset()

func _generate_room_order():
	pass

func reset():
	placed_rooms.clear()
	$Player.reset(Vector2(200, 200))
	
	var dir = Directory.new()
	dir.open(MAP_DIR)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif file.ends_with('.tscn'):
			print(file)
			available_room_files.append(file)
	dir.list_dir_end()

	for m in $MapHolder.get_children():
		m.queue_free()
	for p in $ProjectileHolder.get_children():
		p.queue_free()

	while available_room_files.size() != 0:
		var new_room = spawn_room()
		spawn_enemies(new_room)
	
	var cur_room = placed_rooms[player_grid_pos.x]
	cur_enemy_holder = cur_room.get_node('EnemyHolder')

func _process(delta):
	process_input()
	
	var tile_map = placed_rooms[player_grid_pos.x].get_node('TileMap')
	if not tile_map:
		return
		
	var player_map_pos = $Player.global_position - $Camera2D.position
	var player_coord = tile_map.world_to_map(player_map_pos)
	var tile_index = tile_map.get_cellv(player_coord)
	if tile_index == EMPTY_TILE_INDEX and $Player.state != $Player.STATES.ACTION and abs($Player.height) < 1:
		emit_signal('hit_empty_space')

func spawn_enemies(map):
	if not map:
		return
	var spawn_list = map.get_node('EnemySpawns')
	print('spawn_list:' + str(spawn_list))
	var enemy = load('res://entities/enemies/Enemy.tscn')
	var enemy_red = load('res://entities/enemies/EnemyRed.tscn')
	for e in spawn_list.get_children():
		print('spawn:' + str(e) + ' at ' + str(e.global_position))
		var new_enemy
		if randf()*100 < 50:
			new_enemy = enemy.instance()
			new_enemy.position = e.position
			new_enemy.connect('enemy_leap', self, '_on_Enemy_leap')
			new_enemy.connect('enemy_smash', self, '_on_Enemy_smash')
		else:
			new_enemy = enemy_red.instance()
			new_enemy.position = e.position
			new_enemy.connect('enemy_leap', self, '_on_Enemy_leap')
			new_enemy.connect('enemy_smash', self, '_on_Enemy_smash')
		map.get_node('EnemyHolder').add_child(new_enemy)

func spawn_room():
	print("adding room")
	print(available_room_files.size())
	
	var previous_room = placed_rooms.back() if placed_rooms.size() > 0 else null
	
	var rand_index = randi()%available_room_files.size()
	print(rand_index)
	var map_file_name = available_room_files[rand_index]
	print(map_file_name)
	
	var next_room = load(MAP_DIR + "/" + map_file_name).instance()
	next_room.name = "Map"
	
	var tile_map = next_room.get_node('TileMap')
	cell_size = tile_map.cell_size
	var num_tiles = tile_map.get_used_rect().size
	map_size = num_tiles * cell_size
	
	if previous_room:
		next_room.position = previous_room.position
		next_room.position.x += map_size.x
		
	var door_scn = load("res://environment/Door.tscn")
	if placed_rooms.size() == 0:
		tile_map.set_cell(num_tiles.x-1, 5, GROUND_TILE_INDEX)
		var door_pos = tile_map.map_to_world(Vector2(num_tiles.x-1, 5))
		door_pos += Vector2(cell_size.x/2, cell_size.y/2)
		var door = door_scn.instance()
		door.position = door_pos
		connect('map_complete', door, '_on_Map_complete')
		next_room.get_node('DoorHolder').add_child(door)
	elif available_room_files.size() > 1:
		tile_map.set_cell(0, 5, GROUND_TILE_INDEX)
		tile_map.set_cell(num_tiles.x-1, 5, GROUND_TILE_INDEX)
		var door_pos = tile_map.map_to_world(Vector2(num_tiles.x-1, 5))
		door_pos += Vector2(cell_size.x/2, cell_size.y/2)
		var door = door_scn.instance()
		door.position = door_pos
		connect('map_complete', door, '_on_Map_complete')
		next_room.get_node('DoorHolder').add_child(door)
	else:
		tile_map.set_cell(0, 5, GROUND_TILE_INDEX)
		
	$MapHolder.add_child(next_room)
	
	if $MapHolder/Map/Door:
		connect('map_complete', $MapHolder/Map/Door, '_on_Map_complete')
	if $MapHolder/Map/ExitArea:
		$MapHolder/Map/ExitArea.connect('area_entered', self, '_on_ExitArea_entered')
	
	placed_rooms.append(next_room)
	available_room_files.remove(rand_index)
	
	emit_signal('room_created', $MapHolder/Map)
	
	return next_room

func _on_Player_action_used(world_position):
	var tile_map = placed_rooms[player_grid_pos.x].get_node('TileMap')
	if not tile_map:
		return
	world_position -= $Camera2D.position
	var tile_coord = tile_map.world_to_map(world_position)
	var tile_id = tile_map.get_cellv(tile_coord)
	if not tile_id in WALL_TILE_INDICES:
		tile_map.set_cell(tile_coord.x, tile_coord.y, EMPTY_TILE_INDEX)

func _on_Ability_spawn_projectile(projectile):
	var map = placed_rooms[player_grid_pos.x]
	var bounds = Rect2(map.position, map_size)
	projectile.bounds = bounds
	projectile.connect('projectile_collision', self, '_on_Projectile_collision')
	$ProjectileHolder.add_child(projectile)
	
	$Audio/Shoot.play()

func _on_Projectile_collision(projectile, collider):
	$Audio/Explode.play()
	
	if cur_enemy_holder.get_child_count() == 1:
		if player_grid_pos.x == placed_rooms.size() - 1:
			$Camera2D/WinMenu.display()
			get_tree().paused = true
		emit_signal('map_complete', placed_rooms[player_grid_pos.x])
		
	projectile.queue_free()
	collider.queue_free()

func _on_Enemy_leap(enemy):
	var enemy_pos = enemy.global_position
	var enemy_grid_pos = Vector2(floor(enemy_pos.x/map_size.x), floor(enemy_pos.y/map_size.y))
	var tile_map = placed_rooms[enemy_grid_pos.x].get_node('TileMap')
	if not tile_map:
		return
		
	if enemy_grid_pos == player_grid_pos:
		$Audio/Jump.play()
	
	var smash_pos
	while true:
		var mapx = int(map_size.x/cell_size.x)
		var mapy = int(map_size.y/cell_size.y)
		smash_pos = Vector2(randi()%mapx, randi()%mapy)
		var tile_index = tile_map.get_cellv(smash_pos)
		if not tile_index in WALL_TILE_INDICES:
			break
	var new_pos = tile_map.map_to_world(smash_pos) + cell_size/2
	enemy.smash_pos = new_pos

func _on_Enemy_smash(smash_pos):
	var smash_grid_pos = Vector2(floor(smash_pos.x/map_size.x), floor(smash_pos.y/map_size.y))
	var tile_map = placed_rooms[smash_grid_pos.x].get_node('TileMap')
	if not tile_map:
		return
		
	if smash_grid_pos == player_grid_pos:
		$Audio/Smash.play()
		
	var smash_map_pos = smash_pos - $Camera2D.position
	var tile_coord = tile_map.world_to_map(smash_map_pos)
	var extra_tile_chance = 30 * (smash_grid_pos.x + 1)
	_destroy_tile(tile_map, tile_coord)
	if (tile_coord.x+1) < map_size.x and randf()*100 < extra_tile_chance:
		_destroy_tile(tile_map, Vector2(tile_coord.x+1, tile_coord.y))
	if (tile_coord.x-1) > 0 and randf()*100 < extra_tile_chance:
		_destroy_tile(tile_map, Vector2(tile_coord.x-1, tile_coord.y))
	if (tile_coord.y+1) < map_size.y and randf()*100 < extra_tile_chance:
		_destroy_tile(tile_map, Vector2(tile_coord.x, tile_coord.y+1))
	if (tile_coord.y-1) > 0 and randf()*100 < extra_tile_chance:
		_destroy_tile(tile_map, Vector2(tile_coord.x, tile_coord.y-1))
	if smash_grid_pos.x > 0:
		if (tile_coord.y-1) > 0 and randf()*100 < extra_tile_chance:
			_destroy_tile(tile_map, Vector2(tile_coord.x-1, tile_coord.y-1))
			_destroy_tile(tile_map, Vector2(tile_coord.x+1, tile_coord.y+1))
	if smash_grid_pos.x > 1:
		if (tile_coord.y-1) > 0 and randf()*100 < extra_tile_chance:
			_destroy_tile(tile_map, Vector2(tile_coord.x-1, tile_coord.y-1))
			_destroy_tile(tile_map, Vector2(tile_coord.x+1, tile_coord.y+1))
			_destroy_tile(tile_map, Vector2(tile_coord.x-1, tile_coord.y+1))
			_destroy_tile(tile_map, Vector2(tile_coord.x+1, tile_coord.y-1))

func _on_Player_died():
	$Camera2D/GameOverMenu.display()
	get_tree().paused = true

func _on_Camera2D_change_grid_location(change_direction):
	player_grid_pos += change_direction
	var cur_room = placed_rooms[player_grid_pos.x]
	cur_enemy_holder = cur_room.get_node('EnemyHolder')
	
func _destroy_tile(map, tile_coord):
	var tile_index = map.get_cellv(tile_coord)
	if not tile_index in WALL_TILE_INDICES:
		map.set_cellv(tile_coord, EMPTY_TILE_INDEX)


func _on_IntroAudio_finished():
	$Audio/Soundtrack.play()


func _on_Soundtrack_finished():
	$Audio/Soundtrack.play()


func _on_Player_falling():
	$Audio/Fall.play()


func _on_Player_jump():
	$Audio/PlayerJump.play()
