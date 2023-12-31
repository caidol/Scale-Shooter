extends "res://Scale_Shooter/Scripts/Entities/enemy.gd"

signal in_jump_zone(delta)

@export var slime_is_idle: bool = true
var slime_current_state: int = SLIME_IDLE
var slime_target_range = 300.0
var gravity: int = 2500
var is_in_air: bool = false
var has_jump_offset: bool = true
var entered_jump_zone: bool = false
const RIGHT = Global.RIGHT
const LEFT = Global.LEFT
const UP = Global.UP
@onready var slime_node: CharacterBody2D = $"."
@onready var slime_animation = $AnimatedSprite2D
@onready var health: int = 100

enum {SLIME_IDLE, SLIME_TARGET, SLIME_MOVING, DIE}
signal has_died

func _ready():
	# Check the slime's current state depending on exported idle variable and set correct state
	if (slime_is_idle):
		_change_slime_state(SLIME_IDLE)
	else:
		_change_slime_state(SLIME_MOVING)

func _process(delta):
	if (health <= 0):
		has_died.emit()

func _change_slime_state(state):
	var horizontal_direction = fix_direction_to_horizontal_axis(
		vector_direction_to_player(position.x, position.y, target.position.x, target.position.y)
	)
	
	if (horizontal_direction == RIGHT):
		slime_animation.set_animation("MoveRight")
	else:
		slime_animation.set_animation("MoveLeft")
	
	match state:
		SLIME_IDLE:	
			slime_current_state = SLIME_IDLE
		SLIME_TARGET:
			slime_current_state = SLIME_TARGET
		SLIME_MOVING:
			slime_current_state = SLIME_MOVING

func _physics_process(delta):
	# Set the state to the slime's current state so that it can be checked against
	
	var state: int = slime_current_state
	
	if(!is_on_floor()):
		var horizontal_direction = fix_direction_to_horizontal_axis(
			vector_direction_to_player(position.x, position.y, target.position.x, target.position.y)
		)
		
		if (horizontal_direction == RIGHT):
			slime_animation.set_animation("JumpRight")
		else:
			slime_animation.set_animation("JumpLeft")
		
		velocity.y += gravity * delta
	
	match state:
		SLIME_IDLE:
			# Check if the player falls into the slime's target range
			if (position.distance_to(target.position) <= slime_target_range):
				# change the slime's state to it moving towards the player
				_change_slime_state(SLIME_TARGET)
		SLIME_TARGET:
			if (position.distance_to(target.position) > slime_target_range):
				# change the slime's state to it moving towards the player
				_change_slime_state(SLIME_IDLE)
			
			var direction = vector_direction_to_player(position.x, position.y, target.position.x, target.position.y)
			
			if (is_on_wall() || entered_jump_zone):
				is_in_air = true
				slime_jump(delta)	
			else:
				# Move the enemy in the direction of the vector
				var horizontal_direction = fix_direction_to_horizontal_axis(direction)
				position += horizontal_direction * base_speed * delta
				
	move_and_slide()


func slime_jump(delta):
	var target_pos: Array = [int(target.position.x), int(target.position.y)]
	var slime_pos: Array = [int(position.x), int(position.y)]
	
	var constant = -150
	var vertex = [int(target_pos[0] + ((slime_pos[0] - target_pos[0]) / 2)), target_pos[1] + constant]
	
	# Solve for a 
	var a = float(target_pos[1] - vertex[1]) / ((target_pos[0] - vertex[0]) ** 2)
	
	# Apply the jump by incrementing across x and updating the y-position with equation
	
	# Check for a minimum distance where the slime is able to jump
	if (abs(target_pos[0] - slime_pos[0]) > 50):
		if (is_in_air && target_pos[0] < slime_pos[0]):
			if (has_jump_offset):
				velocity.x += 40
				has_jump_offset = false
				
			velocity.x -= 20 * base_speed * delta
		elif (is_in_air && target_pos[0] > slime_pos[0]):
			if (has_jump_offset):
				velocity.x -= 40
				has_jump_offset = false
				
			velocity.x += 20 * base_speed * delta
	
		velocity.y = (a * ((position.x - vertex[0]) ** 2) + vertex[1]) * base_speed * delta	
	
	if (is_on_floor()):
		is_in_air = false
		has_jump_offset = true
		
	if (entered_jump_zone):
		entered_jump_zone = false
	
func fix_direction_to_horizontal_axis(direction):
	var angle: float = atan2(direction.y, direction.x)
	angle *= (180 / PI)
	
	# Determine where the angle lies between and return a fixed vector depending
	# on which horizontal axis it lies on	
	if (angle >= -90 && angle <= 90):
		return RIGHT
	else:
		return LEFT

func _on_area_2d_area_entered(_area):
	in_jump_zone.emit()
	
func _on_in_jump_zone(_delta):
	entered_jump_zone = true

func _on_has_died():
	slime_node.queue_free()
