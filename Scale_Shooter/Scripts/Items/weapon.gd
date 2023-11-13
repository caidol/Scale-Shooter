extends Node2D

const angular_velocity: float = 0.3
const gun_fixed_point: Vector2 = Vector2(125, -13) 
@onready var player_node: CharacterBody2D = $".." # Retrieve player node to interact with it
@onready var weapon_node: Node2D = $"."

func _ready():
	print(player_node)

func _process(_delta):
	# Retrieve the current mouse position
	
	# Receive potential input to scale the weapon
	scale_weapon()
	
	# Rotate the weapon around a circular motion at a fixed radius length from the player
	
	var mouse_pos = get_global_mouse_position()
	

func scale_weapon():
	# Calculate the offset from the fixed point
	var offset = position - gun_fixed_point
	
	if (Input.is_action_just_released("Mouse wheel up")):
		weapon_node.scale += Vector2(0.5, 0.5)
		
		# Subtract offset position to maintain fixed point
		position = gun_fixed_point - offset * Vector2(0.1, 0.1)
		
	elif (Input.is_action_just_released("Mouse wheel down")):
		weapon_node.scale -= Vector2(0.5, 0.5)
		
		# Add offset to adjust position to maintain a fixed point
		position = gun_fixed_point + offset * Vector2(0.1, 0.1)
