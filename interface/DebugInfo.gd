extends Control

enum STATES {IDLE, WALK, ACTION, JUMP, FALLING, DEAD}

func _ready():
	pass

func _on_Entity_state_changed(new_state):
	$StateLabel.text = ''
	
	match new_state:
		IDLE:
			$StateLabel.text = 'IDLE'
		WALK:
			$StateLabel.text = 'WALK'
		ACTION:
			$StateLabel.text = 'ACTION'
		JUMP:
			$StateLabel.text = 'JUMP'
		FALLING:
			$StateLabel.text = 'FALLING'
		DEAD:
			$StateLabel.text = 'DEAD'
		_:
			
			$StateLabel.text = 'UNKNOWN'
