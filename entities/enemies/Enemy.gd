extends KinematicBody2D

signal state_changed

enum STATES {IDLE, MOVE}

const MAX_SPEED = 75

const MIN_STATE_WAIT_TIME = 1
const MAX_STATE_WAIT_TIME = 4

var state

var velocity = Vector2()

func _ready():
	_change_state(IDLE)

func _physics_process(delta):
	move_and_slide(velocity)

func _change_state(new_state):
	if new_state == state:
		return
	
	state = new_state
	match state:
		IDLE:
			velocity = Vector2()
			
			$AnimationPlayer.play('idle')
		MOVE:
			var direction = Vector2(randf()*2-1, randf()*2-1)
			velocity = direction.normalized() * MAX_SPEED
			
			$AnimationPlayer.play('walk')
	
	$StateChangeTimer.wait_time =randi()%(MAX_STATE_WAIT_TIME+1) + MIN_STATE_WAIT_TIME
	$StateChangeTimer.start()
	emit_signal('state_changed', new_state)

func _on_StateChangeTimer_timeout():
	if state == IDLE:
		_change_state(MOVE)
	elif state == MOVE:
		_change_state(IDLE)
