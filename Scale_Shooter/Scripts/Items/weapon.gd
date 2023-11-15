extends Node2D

# constant defs
const angular_velocity: float = 0.3
const weapon_radius: int = 120
const scale_lower_bound: Vector2 = Vector2(0.5, 0.5)
const scale_upper_bound: Vector2 = Vector2(4.5, 4.5)
const gun_fixed_point: Vector2 = Vector2(120, -15) 

@onready var player_node: CharacterBody2D = $".." # Retrieve player node to interact with it
@onready var weapon_node: Node2D = $"."

func _ready():
	print(player_node)

func _process(_delta):
	# Retrieve the current mouse position
	
	# Receive potential input to scale the weapon
	scale_weapon()
	
	# Rotate the weapon around a circular motion at a fixed radius length from the player
	rotate_weapon()

func scale_weapon():
	# Calculate the offset from the fixed point
	var offset = position - gun_fixed_point
	
	if (Input.is_action_just_released("Mouse wheel up") && weapon_node.scale < scale_upper_bound):
		weapon_node.scale += Vector2(0.5, 0.5)
		
		# Subtract offset position to maintain fixed point
		position = gun_fixed_point - offset * Vector2(0.1, 0.1)
		
	elif (Input.is_action_just_released("Mouse wheel down") && weapon_node.scale > scale_lower_bound):
		weapon_node.scale -= Vector2(0.5, 0.5)
		
		# Add offset to adjust position to maintain a fixed point
		position = gun_fixed_point + offset * Vector2(0.1, 0.1)

func rotate_weapon():
	# Retrieve the current mouse position and angle to mouse
	var mouse_position = get_global_mouse_position()
	var mouse_angle = player_node.position.angle_to(mouse_position)
	
	# set the weapon position relative to mouse position
