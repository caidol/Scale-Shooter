extends "enemy.gd"

signal in_jump_zone(delta)

@export var slime_is_idle: bool = true
var slime_current_state: int = SLIME_IDLE
var slime_target_range = 300.0
var gravity: int = 2500
var is_in_air: bool = false
var has_jump_offset: bool = false
var entered_jump_zone: bool = false
const RIGHT = Global.RIGHT
const LEFT = Global.LEFT
const UP = Global.UP 

enum {SLIME_IDLE, SLIME_TARGET, SLIME_MOVING, DIE}

func _ready():
	# Check the slime's current state depending on exported idle variable and set correct state
	if (slime_is_idle):
		_change_slime_state(SLIME_IDLE)
	else:
		_change_slime_state(SLIME_MOVING)

func _change_slime_state(state):
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
	
	#var target_pos: Array = [1, 0]
	#var slime_pos: Array = [4, 3]
	
	'''
	# Create a parabola -> -ax^2 + bx + c for the slime to jump along
	#
	# Equation 1 -> target_pos[1] = a * (target_pos[0] ** 2) + b * (target_pos[0]) + c
	# Equation 2 -> slime_pos[1] = a * (slime_pos[0] ** 2) + b * (slime_pos[0]) + c
	
	const weight = 8.0 / 10000
	var a = (-weight * gravity)
	
	# Solve for b:
	# 
	# target_pos[1] - slime_pos[1] = a * (target_pos[0] ** 2 - slime_pos[0] ** 2) + b(target_pos[0] - slime_pos[0])
	# 
	# b = ((target_pos[1] - slime_pos[1]) - a * (target_pos[0] ** 2 - slime_pos[0] ** 2)) / (target_pos[0] - slime_pos[0])
	
	#var b = ((target_pos[1] - slime_pos[1]) - (-a) * (target_pos[0] ** 2 - slime_pos[0] ** 2)) / (target_pos[0] - slime_pos[0])
	
	var b = (
		((slime_pos[1] - target_pos[1])
		- (-a) * (target_pos[0] ** 2 - slime_pos[0] ** 2))
		/ (slime_pos[0] - target_pos[0])
	)
	
	# Solve for c:
	#
	# c = target_pos[1] - a * (target_pos[0] ** 2) - b * (target_pos[0])
	#
	# Note: The above can work with equation 2 also
	
	#var c = target_pos[1] - (-a) * (target_pos[0] ** 2) - b * (target_pos[0])
	
	var c = (
		target_pos[1] - (-a) * (target_pos[0] ** 2) - b * (target_pos[0])
	)
	'''
	
	# Other idea below
	
	var constant = -150
	var vertex = [int(target_pos[0] + ((slime_pos[0] - target_pos[0]) / 2)), target_pos[1] + constant]
	print("vertex: ", vertex)
	
	# Solve for a 
	var a = float(target_pos[1] - vertex[1]) / ((target_pos[0] - vertex[0]) ** 2)
	
	# Apply the jump by incrementing across x and updating the y-position with equation
	
	# Check for a minimum distance where the slime is able to jump
	if (abs(target_pos[0] - slime_pos[0]) > 50):
		if (is_in_air && target_pos[0] < slime_pos[0]):
			print("LEFT")
			velocity.x -= 20 * base_speed * delta
		elif (is_in_air && target_pos[0] > slime_pos[0]):
			print("RIGHT")
			velocity.x += 20 * base_speed * delta
	
		velocity.y = (a * ((position.x - vertex[0]) ** 2) + vertex[1]) * base_speed * delta	
	
	if (is_on_floor()):
		is_in_air = false
		has_jump_offset = false
		
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

func _on_area_2d_area_entered(area):
	in_jump_zone.emit()

func _on_in_jump_zone(delta):
	entered_jump_zone = true
