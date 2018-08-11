extends KinematicBody2D

enum STATES {IDLE, WALK}

const MAX_SPEED = 150
const ACCELERATION = 10

var velocity = Vector2()

var state = IDLE

onready var primary_action = $FireSpellAbility
onready var secondary_action = $FireSpellAbility

func process_input():
	var move_velocity = Vector2()
	if Input.is_action_pressed("move_up"):
		move_velocity.y -= 1
	if Input.is_action_pressed("move_down"):
		move_velocity.y += 1
	if Input.is_action_pressed("move_left"):
		move_velocity.x -= 1
	if Input.is_action_pressed("move_right"):
		move_velocity.x += 1
	if Input.is_action_pressed("primary_action"):
		if primary_action:
			primary_action.use();
	
	velocity += move_velocity.normalized() * ACCELERATION
	if velocity.length() > MAX_SPEED:
		velocity = velocity.clamped(MAX_SPEED)
	
	if move_velocity.x == 0 or (velocity.x < 0 and move_velocity.x > 0) or (velocity.x > 0 and move_velocity.x < 0):
		velocity.x = 0
	if move_velocity.y == 0 or (velocity.y < 0 and move_velocity.y > 0) or (velocity.y > 0 and move_velocity.y < 0):
		velocity.y = 0

func _ready():
	_change_state(IDLE)

func _change_state(new_state):
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		WALK:
			$AnimationPlayer.play("walk")

func _process(delta):
	match state:
		IDLE:
			if velocity.length() > 0:
				_change_state(WALK)
		WALK:
			if velocity.length() == 0:
				_change_state(IDLE)

func _physics_process(delta):
	process_input()
	move_and_slide(velocity)