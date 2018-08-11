extends Node2D

signal hit_empty_space

const MAP_DIR = "res://maps"

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
	
	spawn_room()

func _process(delta):
	var tile_map = $MapHolder/Map/TileMap
	var player_coord = tile_map.world_to_map($Player.global_position)
	var tile_index = tile_map.get_cellv(player_coord)
	if tile_index == -1 and $Player.state != $Player.STATES.ACTION and abs($Player.height) < 1:
		emit_signal('hit_empty_space')

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
	tile_map.set_cell(tile_coord.x, tile_coord.y, -1)


func _on_Player_died():
	print('game over')
