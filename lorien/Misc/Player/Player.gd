class_name Player
extends CharacterBody2D

# -------------------------------------------------------------------------------------------------
@export var speed: float = 600
@export var jump_power: float = 1000
@export var gravity: float = 60

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _col_shape_normal: CollisionShape2D = $CollisionShapeNormal
@onready var _col_shape_crouching: CollisionShape2D = $CollisionShapeCrouching

# -------------------------------------------------------------------------------------------------
func _physics_process(delta: float) -> void:
	var is_crouching := false
	velocity.y += gravity
	if Input.is_action_pressed("player_crouch"):
		is_crouching = true
		_sprite.play("crouch")
	elif Input.is_action_pressed("player_move_left"):
		velocity.x = -speed
		_sprite.play("walk")
		_sprite.flip_h = true
	elif Input.is_action_pressed("player_move_right"):
		velocity.x = speed
		_sprite.play("walk")
		_sprite.flip_h = false
	elif is_on_floor():
		velocity.x = 0
		_sprite.play("idle")

	if is_on_floor() && Input.is_action_just_pressed("player_jump"):
		velocity.y -= jump_power
		_sprite.play("jump")

	_col_shape_crouching.disabled = !is_crouching
	_col_shape_normal.disabled = is_crouching

	move_and_slide()

# -------------------------------------------------------------------------------------------------
func reset(global_pos: Vector2) -> void:
	global_position = global_pos
	velocity = Vector2.ZERO
