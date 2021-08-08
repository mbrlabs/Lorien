class_name Player
extends KinematicBody2D

# -------------------------------------------------------------------------------------------------
export var speed: float = 400
export var jump_power: float = 1000
export var gravity: float = 60
onready var _sprite: AnimatedSprite = $AnimatedSprite
onready var _col_shape_normal: CollisionShape2D = $CollisionShapeNormal
onready var _col_shape_crouching: CollisionShape2D = $CollisionShapeCrouching
var _velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var is_crouching := false
	_velocity.y += gravity
	if Input.is_action_pressed("player_move_left"):
		_velocity.x = -speed
		_sprite.play("walk")
		_sprite.flip_h = true
	elif Input.is_action_pressed("player_move_right"):
		_velocity.x = speed
		_sprite.play("walk")
		_sprite.flip_h = false
	elif Input.is_action_pressed("player_crouch"):
		is_crouching = true
		_sprite.play("crouch")
	elif is_on_floor():
		_velocity.x = 0
		_sprite.play("idle")
		
	if is_on_floor() && Input.is_action_just_pressed("player_jump"):
		_velocity.y -= jump_power
		_sprite.play("jump")
	
	_col_shape_crouching.disabled = !is_crouching
	_col_shape_normal.disabled = is_crouching
		

	_velocity = move_and_slide(_velocity, Vector2.UP, false, 4, PI/4.0, false)

# -------------------------------------------------------------------------------------------------
func reset(global_pos: Vector2) -> void:
	global_position = global_pos
	_velocity = Vector2.ZERO
