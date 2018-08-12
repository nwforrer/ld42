extends KinematicBody2D

signal state_changed
signal enemy_leap
signal enemy_smash

enum STATES {IDLE, MOVE, LEAP, IN_AIR, SMASH}

const MAX_SPEED = 75

const MIN_STATE_WAIT_TIME = 1
const MAX_STATE_WAIT_TIME = 4

const LEAP_STATE_CHANCE = 50 # percent chance of leaping instead of moving

var state

var smash_pos = Vector2()
var velocity = Vector2()

func _ready():
	_change_state(IDLE)

func _physics_process(delta):
	move_and_slide(velocity)

func _change_state(new_state):
	if new_state == state:
		return
	
	var state_time = 1
	
	state = new_state
	match state:
		IDLE:
			velocity = Vector2()
			
			state_time = randi()%(MAX_STATE_WAIT_TIME+1) + MIN_STATE_WAIT_TIME
			
			$AnimationPlayer.play('idle')
		MOVE:
			var direction = Vector2(randf()*2-1, randf()*2-1)
			velocity = direction.normalized() * MAX_SPEED
			
			state_time = randi()%(MAX_STATE_WAIT_TIME+1) + MIN_STATE_WAIT_TIME
			
			$AnimationPlayer.play('walk')
		LEAP:
			state_time = 0.5
			
			$CollisionShape2D.disabled = true
			
			$AnimationPlayer.play('leap')
			emit_signal('enemy_leap', self)
		IN_AIR:
			state_time = 2
			
			position = smash_pos
			
			$shadow.scale = Vector2(1, 1)
		SMASH:
			state_time = 0.1
			
			$CollisionShape2D.disabled = false
			
			emit_signal('enemy_smash', global_position)
	
	$StateChangeTimer.wait_time = state_time
	$StateChangeTimer.start()
	emit_signal('state_changed', new_state)

func _on_StateChangeTimer_timeout():
	if state == IDLE:
		var state_change = randi()%101+1
		if state_change < LEAP_STATE_CHANCE:
			_change_state(LEAP)
		else:
			_change_state(MOVE)
	elif state == MOVE:
		_change_state(IDLE)
	elif state == LEAP:
		_change_state(IN_AIR)
	elif state == IN_AIR:
		_change_state(SMASH)
	elif state == SMASH:
		_change_state(MOVE)
