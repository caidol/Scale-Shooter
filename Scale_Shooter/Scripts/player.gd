extends CharacterBody2D

const SPEED = 900
const JUMP_VELOCITY = -500.0
@onready var sprite_animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var prev_dir: int = 1 # Map 0 to looking left and 1 to right

# Get the gravity from the project settings to be synced with node
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(_delta):
	process_input()

func process_input():
	if (Input.is_action_pressed("Space")):
		if prev_dir == 1:
			sprite_animation.set_animation("JumpRight")
		else:
			sprite_animation.set_animation("JumpLeft")
	elif (Input.is_action_pressed("A")):
		sprite_animation.set_animation("MoveLeft")
		prev_dir = 0
	elif (Input.is_action_pressed("D")):
		sprite_animation.set_animation("MoveRight")
		prev_dir = 1
	else:
		if prev_dir == 1:
			sprite_animation.set_animation("IdleRight")
		else:
			sprite_animation.set_animation("IdleLeft")
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
		'''
		if prev_dir == 1:
			sprite_animation.set_animation("JumpRight")
		else:
			sprite_animation.set_animation("JumpLeft")
		'''

	# Handle Jump.
	if Input.is_action_pressed("Space") and is_on_floor():
		'''
		print("test0")
		if prev_dir == 1:
			print("test1")
			sprite_animation.set_animation("JumpRight")
		else:
			print("test2")
			sprite_animation.set_animation("JumpLeft")
		'''

		velocity.y = JUMP_VELOCITY
		
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("A", "D")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
