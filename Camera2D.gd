extends Camera2D

onready var player = get_parent().get_node('Player')

var screen_size
var map

func _ready():
	screen_size = OS.get_real_window_size()
	#offset = screen_size / 2
	
func _physics_process(delta):
	if not map:
		return
	
	var tile_map = map.get_node('TileMap')
	
	var player_pos = player.position
	var camera_pos = position
	var cell_size = tile_map.cell_size
	var map_size = tile_map.get_used_rect().size * cell_size
	
	if player_pos.x > position.x + map_size.x:
		position.x += map_size.x
	elif player_pos.x < position.x:
		position.x -= map_size.x
	print(position)

func _on_Game_room_created(new_map):
	map = new_map
