extends "res://Scale_Shooter/Scripts/Entities/enemy.gd"

enum {DRONE_IDLE, DRONE_TARGET}

@onready var drone_animation = $AnimatedSprite2D
@onready var health: int = 100
var drone_current_state: int = DRONE_IDLE 
var drone_target_range = 300.0
var gravity: int = 2500

signal has_died

func _process(delta):
	if (health <= 0):
		has_died.emit()

func _change_drone_state(state):
	var player_angle = atan2(abs(target.position.y - position.y), abs(target.position.x - position.x))
	
	if (player_angle >= -90 || player_angle <= 90):
		drone_animation.set_animation("MoveRight")
	else:
		drone_animation.set_animation("MoveLeft")
	
	match state:
		DRONE_IDLE:
			drone_current_state = DRONE_IDLE
		DRONE_TARGET:
			drone_current_state = DRONE_TARGET

func _physics_process(delta):
	# Set the state to the drone's current state so that it can be checked against
	
	var state: int = drone_current_state
	
	match state:
		DRONE_IDLE:
			if (position.distance_to(target.position) <= drone_target_range):
				# change the drone's state to it moving towards the player
				_change_drone_state(DRONE_TARGET)
		DRONE_TARGET:
			if (position.distance_to(target.position) > drone_target_range):
				# change the slime's state to it moving towards the player
				_change_drone_state(DRONE_IDLE)
				
			var direction = vector_direction_to_player(position.x, position.y, target.position.x, target.position.y)
			
			# Move the drone so that it's targeting whichever direction that the player is in
			position += direction * base_speed * delta

	move_and_slide()
