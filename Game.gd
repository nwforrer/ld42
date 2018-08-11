extends Node2D

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

func spawn_room():
	print("adding room")
	print(available_room_files.size())
	
	rand_seed(1)
	var rand_index = randi()%available_room_files.size()
	print(rand_index)
	var map_file_name = available_room_files[rand_index]
	print(map_file_name)
	
	var next_room = load(MAP_DIR + "/" + map_file_name).instance()
	$MapHolder.add_child(next_room)
	
	current_room = next_room