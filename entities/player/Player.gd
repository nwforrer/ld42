extends KinematicBody2D

signal action_used
signal state_changed
signal falling
signal died
signal jump

enum STATES {IDLE, WALK, ACTION, JUMP, FALLING}

const MAX_SPEED = 150
const ACCELERATION = 10

const BUMP_DURATION = 0.2
const MIN_BUMP_DISTANCE = 10
const BUMP_DISTANCE = 80
const MAX_BUMP_HEIGHT = 50

const JUMP_DURATION = 0.8
const MAX_JUMP_HEIGHT = 80

const RAY_CAST_LENGTH = 90

onready var primary_action = $FireSpellAbility
onready var secondary_action = $FireSpellAbility

onready var camera = get_parent().get_node('Camera2D')

var can_shoot = true

var height = 0.0 setget set_height

var velocity = Vector2()
var air_speed = 0.0
var air_velocity = 0.0

var facing = Vector2(1, 0) setget set_facing

var state

func _input(event):
	if event is InputEventMouseMotion:
		var map_pos = global_position - camera.position
		var mouse_dist = event.position - map_pos
		self.facing = Vector2(mouse_dist.x, 0) if abs(mouse_dist.x) > abs(mouse_dist.y) else Vector2(0, mouse_dist.y)

func process_input():
	if state in [FALLING]:
		return
		
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
		if state in [IDLE, WALK]:
			if primary_action and can_shoot:
				can_shoot = false
				$ActionTimer.start()
				primary_action.use(facing.normalized())
				emit_signal("action_used", $Pivot.global_position)
				_change_state(ACTION)
			
	if Input.is_action_pressed("jump"):
		if state in [IDLE, WALK]:
			print("start pivot position:" + str($Pivot.position))
			_change_state(JUMP)
	
	velocity += move_velocity.normalized() * ACCELERATION
	if velocity.length() > MAX_SPEED:
		velocity = velocity.clamped(MAX_SPEED)
	
	if move_velocity.x == 0 or (velocity.x < 0 and move_velocity.x > 0) or (velocity.x > 0 and move_velocity.x < 0):
		velocity.x = 0
	if move_velocity.y == 0 or (velocity.y < 0 and move_velocity.y > 0) or (velocity.y > 0 and move_velocity.y < 0):
		velocity.y = 0

func reset(position):
	_change_state(IDLE)
	global_position = position

func _ready():
	$Tween.connect('tween_completed', self, '_on_Tween_tween_completed')
	reset(Vector2(100,100))

func _change_state(new_state):
	if new_state == state:
		return
		
	emit_signal('state_changed', new_state)
	state = new_state
	match state:
		IDLE:
			$AnimationPlayer.play("idle")
		WALK:
			$AnimationPlayer.play("walk")
		ACTION:
			$AnimationPlayer.stop()
			var bump_dist = BUMP_DISTANCE if not $BackRayCast.is_colliding() else MIN_BUMP_DISTANCE
			$Tween.interpolate_property(self, 'position', position, position + bump_dist * -facing.normalized(), BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.interpolate_method(self, '_animate_bump_height', 0, 1, BUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		JUMP:
			emit_signal('jump')
			air_speed = velocity.length()
			air_velocity = velocity
			$AnimationPlayer.play('jump')
			
			$Tween.interpolate_method(self, '_animate_jump_height', 0, 1, JUMP_DURATION, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		FALLING:
			emit_signal('falling')
			$AnimationPlayer.play("falling")
			velocity = Vector2()

func _process(delta):
	if facing.x < 0:
		$Pivot.scale.x = -1
	else:
		$Pivot.scale.x = 1
	
	if facing.y > 0:
		$Pivot.hide()
		$PivotFront.show()
		$PivotBack.hide()
	elif facing.y < 0:
		$Pivot.hide()
		$PivotFront.hide()
		$PivotBack.show()
	else:
		$Pivot.show()
		$PivotFront.hide()
		$PivotBack.hide()
	
	if state == IDLE and velocity.length() > 0:
		_change_state(WALK)
	elif state == WALK:
		if velocity.length() == 0:
			_change_state(IDLE)

func _physics_process(delta):
	process_input()
	move_and_slide(velocity)
	
func _animate_bump_height(progress):
	self.height = pow(sin(progress * PI), 0.4) * MAX_BUMP_HEIGHT
	
func _animate_jump_height(progress):
	self.height = pow(sin(progress * PI), 0.7) * MAX_JUMP_HEIGHT

func _on_ActionTimer_timeout():
	can_shoot = true
	
func _on_Tween_tween_completed(object, key):
	if key == ":_animate_bump_height":
		_change_state(IDLE)
	if key == ":_animate_jump_height":
		print("end pivot position:" + str($Pivot.position))
		_change_state(IDLE)
	
func set_height(value):
	height = value
	$Pivot.position.y = -height
	$PivotFront.position.y = -height
	$PivotBack.position.y = -height
	var shadow_scale = 1.0 - value / MAX_JUMP_HEIGHT * 0.5
	$Shadow.scale = Vector2(shadow_scale, shadow_scale)

func _on_Game_hit_empty_space():
	_change_state(FALLING)

func _on_AnimationPlayer_animation_finished(anim_name):
	if state == FALLING:
		emit_signal('died')

func set_facing(new_facing):
	facing = new_facing
	$BackRayCast.cast_to = -facing.normalized() * RAY_CAST_LENGTH