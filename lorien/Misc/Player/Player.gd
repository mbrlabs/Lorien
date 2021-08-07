class_name Player
extends KinematicBody2D

# -------------------------------------------------------------------------------------------------
enum State {
	IDLE,
	MOVING,
	JUMPING,
	LANDING
}

# -------------------------------------------------------------------------------------------------
export var speed: float = 250
export var jump_power: float = 1500
export var push_power: float = 100
export var gravity: float = 120
onready var _sprite: AnimatedSprite = $AnimatedSprite
var _state = State.IDLE
var _velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	_velocity.y += gravity
	if Input.is_action_pressed("player_move_left"):
		_velocity.x = -speed
		_sprite.play("walk")
		_sprite.flip_h = true
	elif Input.is_action_pressed("player_move_right"):
		_velocity.x = speed
		_sprite.play("walk")
		_sprite.flip_h = false
	elif is_on_floor():
		_velocity.x = 0
		_sprite.play("idle")
	
	if is_on_floor() && Input.is_action_just_pressed("player_jump"):
		_velocity.y -= jump_power
		_sprite.play("jump")
	
	match _state:
		State.IDLE: _state_idle(delta)
		State.MOVING: _state_moving(delta)
		State.JUMPING: _state_jumping(delta)
		State.LANDING: _state_landing(delta)
	_velocity = move_and_slide(_velocity, Vector2.UP, false, 4, PI/4.0, false)

# -------------------------------------------------------------------------------------------------
func reset(global_pos: Vector2) -> void:
	global_position = global_pos
	_velocity = Vector2.ZERO
	_state = State.IDLE

# -------------------------------------------------------------------------------------------------
func _state_idle(delta: float) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _state_moving(delta: float) -> void:
	pass
	
# -------------------------------------------------------------------------------------------------
func _state_jumping(delta: float) -> void:
	pass

# -------------------------------------------------------------------------------------------------
func _state_landing(delta: float) -> void:
	pass
