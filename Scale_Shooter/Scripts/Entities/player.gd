extends CharacterBody2D

const SPEED = 700	
const JUMP_VELOCITY = -1000.0
const FLOOR_NORMAL = Vector2.UP
var gravity = 2500 # Set a default value for gravity to determine how fast the player falls.
var is_jumping: bool = false
var mouse_angle: float
var was_on_floor: bool
@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var head_torch: PointLight2D = $HeadTorch
@onready var coyote_timer: Timer = $Timers/CoyoteTimer
@onready var jump_buffer: Timer = $Timers/JumpBuffer
@onready var jump_audio: AudioStreamPlayer2D = $PlayerAudio/Jump
@onready var land_audio: AudioStreamPlayer2D = $PlayerAudio/Land
@onready var walk_audio: AudioStreamPlayer2D = $PlayerAudio/Walk
@onready var player_health_bar = $UI/ProgressBars/HealthBar
@onready var prev_dir: int = 1 # Map 0 to looking left and 1 to right

@export var health: int = 100

signal has_been_damaged
signal has_died

func _process(_delta):
	if (health <= 0):
		has_died.emit()
	
	# Process the player input 
	process_input()
	
	# * Important function to process all player physics and allow them to function
	move_and_slide()
	
	# Fix the issue below where the player is unable to run up slopes by finding
	# the angle to the floor and forming a normalised vector for the player to 
	# travel along
	
	var floor_angle: float = get_floor_angle()
	#print("floor angle: ", floor_angle * (180 / PI))
	#print("floor normal: ", get_floor_normal())
	
	# Play relevant audio files
	if (Input.is_action_just_pressed("Space")):
		jump_audio.play()
	elif (Input.is_action_just_pressed("A") || Input.is_action_pressed(("D"))):
		walk_audio.play()

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
			head_torch.position.x = -35.5
			prev_dir = 1
		elif (Input.is_action_pressed("A") and prev_dir != 0):
			sprite_animation.set_animation("JumpLeft")
			head_torch.position.x = 35.5
			prev_dir = 0
	
	# Map the standard movement keys including jumping
	if (Input.is_action_pressed("Space")):
		if (is_on_floor()):
			# Start the jump buffer timer 
			jump_buffer.start()

		is_jumping = true
		
		if prev_dir == 1:
			sprite_animation.set_animation("JumpRight")
			head_torch.position.x = -35.5
		else:
			sprite_animation.set_animation("JumpLeft")
			head_torch.position.x = 35.5
	elif (Input.is_action_pressed("A") and is_on_floor()):
		sprite_animation.set_animation("MoveLeft")
		head_torch.position.x = 35.5
		prev_dir = 0
	elif (Input.is_action_pressed("D") and is_on_floor()):
		sprite_animation.set_animation("MoveRight")
		head_torch.position.x = -35.5
		prev_dir = 1
	else:
		if is_on_floor():
			if (!was_on_floor):
				land_audio.play()
			
			is_jumping = false
			if ((mouse_angle * 180 / PI) < -90 || (mouse_angle * 180 / PI) > 90):
				sprite_animation.set_animation("IdleLeft")
				head_torch.position.x = 35.5
			else:
				sprite_animation.set_animation("IdleRight")
				head_torch.position.x = -35.5
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		if prev_dir == 1:
			sprite_animation.animation = "JumpRight"
		else:
			sprite_animation.animation = "JumpLeft"
		
		if (!is_on_floor() && coyote_timer.time_left > 0):
			velocity.y += 0 * delta
		else:
			velocity.y += gravity * delta
		
	# Handle Jump.
	if (Input.is_action_pressed("Space") && is_on_floor()):
		velocity.y = JUMP_VELOCITY
	elif (Input.is_action_pressed("Space") && coyote_timer.time_left > 0):
		# Apply jump velocity
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
	elif (Input.is_action_pressed("Space") && !(is_on_floor()) && jump_buffer.time_left > 0): 
		velocity.y = JUMP_VELOCITY
		jump_buffer.stop()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("A", "D")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	was_on_floor = is_on_floor()
	apply_coyote_time()
	
func apply_coyote_time():
	if (was_on_floor && !is_on_floor() && !is_jumping):
		coyote_timer.start()
		
func _on_collision_boundary_body_entered(body):
	if ((body.name).substr(0, 5) == "Slime" || (body.name).substr(0, 5) == "Drone"):
		health -= 20
