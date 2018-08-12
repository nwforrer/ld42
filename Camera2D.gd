extends Camera2D

signal change_grid_location

onready var player = get_parent().get_node('Player')

var map
var map_size
	
func _physics_process(delta):
	if not map:
		return
	
	var player_pos = player.position
	var camera_pos = position
	
	if map_size.x > 1024:
		print('fail')
	
	if player_pos.x > position.x + map_size.x:
		position.x += map_size.x
		emit_signal('change_grid_location', Vector2(1, 0))
	elif player_pos.x < position.x:
		position.x -= map_size.x
		emit_signal('change_grid_location', Vector2(-1, 0))

func _on_Game_room_created(new_map):
	if map:
		return
		
	map = new_map
	
	var tile_map = map.get_node('TileMap')
	var cell_size = tile_map.cell_size
	var used_tile_size = tile_map.get_used_rect().size
	map_size = used_tile_size * cell_size
