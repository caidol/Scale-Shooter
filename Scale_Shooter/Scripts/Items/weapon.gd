extends Node2D

# constant defs
const angular_velocity: float = 0.3
const weapon_radius: int = 120.9338662
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
	# Retrive mouse and player position
	var mouse_position: Array = [
		get_global_mouse_position().x,
		get_global_mouse_position().y
	]
	var player_position: Array = [
		player_node.position.x, 
		player_node.position.y
	]
	
	var angle = atan2(
		mouse_position[1] - player_position[1],
		mouse_position[0] - player_position[0]
	)
	
	var weapon_x = player_position[0] + weapon_radius * cos(angle)
	var weapon_y = player_position[1] + weapon_radius * sin(angle)

	global_position = Vector2(weapon_x, weapon_y)
	
	rotation_degrees = angle * 180 / PI
	print(angle * 180 / PI)
	
	# perform checks in terms of when to flip the weapon sprite upon passing over
	# a certain limit 
	
	
