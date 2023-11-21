extends CharacterBody2D

const SPEED = 700	
const JUMP_VELOCITY = -1000.0
var gravity = 2500 # Set a default value fpr gravity to determine how fast the player falls.
var is_jumping: bool = false
var mouse_angle: float
var was_on_floor: bool
@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var prev_dir: int = 1 # Map 0 to looking left and 1 to right

func _process(_delta):
	process_input()

func process_input():
	# Calculate angle of mouse from player 
	mouse_angle = atan2(
		get_global_mouse_position().y - position.y,
		get_global_mouse_position().x - position.x
	)
	
	# Allow the player to change jump direction in the air
	if !is_on_floor():
		if (Input.is_action_pressed("D") and prev_dir != 1):
			sprite_animation.set_animation("JumpRight")
			prev_dir = 1
		elif (Input.is_action_pressed("A") and prev_dir != 0):
			sprite_animation.set_animation("JumpLeft")
			prev_dir = 0
	
	# Map the standard movement keys including jumping
	if (Input.is_action_pressed("Space")):
		is_jumping = true 
		
		if prev_dir == 1:
			sprite_animation.set_animation("JumpRight")
		else:
			sprite_animation.set_animation("JumpLeft")
	elif (Input.is_action_pressed("A") and is_on_floor()):
		sprite_animation.set_animation("MoveLeft")
		prev_dir = 0
	elif (Input.is_action_pressed("D") and is_on_floor()):
		sprite_animation.set_animation("MoveRight")
		prev_dir = 1
	else:
		if is_on_floor():
			is_jumping = false
			if ((mouse_angle * 180 / PI) < -90 || (mouse_angle * 180 / PI) > 90):
				sprite_animation.set_animation("IdleLeft")
			else:
				sprite_animation.set_animation("IdleRight")
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if prev_dir == 1:
			sprite_animation.animation = "JumpRight"
		else:
			sprite_animation.animation = "JumpLeft"
		
		if (coyote_timer.time_left > 0 && !is_jumping):
			velocity.y += 0 * delta
		else:
			velocity.y += gravity * delta
		
	# Handle Jump.
	if (Input.is_action_pressed("Space") && is_on_floor()):
		velocity.y = JUMP_VELOCITY
	#elif (Input.is_action_pressed("Space") && coyote_timer.time_left > 0):
		# Apply jump velocity
		#velocity.y = JUMP_VELOCITY
		#coyote_timer.stop()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("A", "D")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	was_on_floor = is_on_floor()
	move_and_slide()
	apply_coyote_time()
	
func apply_coyote_time():
	if (was_on_floor && !is_on_floor() && !is_jumping):
		coyote_timer.start()
