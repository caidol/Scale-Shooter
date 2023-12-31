extends Node2D

# constant defs
const angular_velocity: float = 0.3
const gun_fixed_point: Vector2 = Vector2(80, -60)
const weapon_radius: int = sqrt(pow(gun_fixed_point[0], 2) + pow(gun_fixed_point[1], 2))

signal laser_appears(delta, direction: Vector2)

var weapon_energy: int = 100
@export var scale_lower_bound: Vector2 = Vector2(1.5, 1.5)
@export var scale_upper_bound: Vector2 = Vector2(6.5, 6.5)
@onready var player_node: CharacterBody2D = $".." # Retrieve player node to interact with it
@onready var weapon_node: Node2D = $"."
@onready var ScaleUp: AudioStreamPlayer2D = $Audio/ScaleUp
@onready var ScaleDown: AudioStreamPlayer2D = $Audio/ScaleDown
@onready var Laser: AudioStreamPlayer2D = $Audio/Laser
@onready var weapon_sprite: Sprite2D = $Idle
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var projectile_scene: PackedScene = preload("res://Scale_Shooter/Scenes/Projectiles/projectile.tscn")
@onready var prev_angle = null

func _ready():
	# Immediately update the weapon node to a mid scale -> Vector2(4.5, 4.5)
	weapon_node.apply_scale(Vector2(3, 3))
	
func _process(delta):
	# Retrieve the current mouse position
	#print("weapon scale: ", scale.x)
	
	# Receive potential input to scale the weapon
	scale_weapon()
	
	# Rotate the weapon around a circular motion at a fixed radius length from the player
	rotate_weapon(delta)

func scale_weapon():
	# Calculate the offset from the fixed point
	var offset = position - gun_fixed_point
	
	if (Input.is_action_just_released("Mouse wheel up") && weapon_node.scale < scale_upper_bound):
		ScaleUp.play()
		weapon_node.scale += Vector2(0.5, 0.5)
		
		# Subtract offset position to maintain fixed point
		position = gun_fixed_point - offset * Vector2(0.1, 0.1)
		
	elif (Input.is_action_just_released("Mouse wheel down") && weapon_node.scale > scale_lower_bound):
		ScaleDown.play()
		weapon_node.scale -= Vector2(0.5, 0.5)
		
		# Add offset to adjust position to maintain a fixed point
		position = gun_fixed_point + offset * Vector2(0.1, 0.1)

func rotate_weapon(delta):
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
	
	# perform checks in terms of when to flip the weapon sprite upon passing over
	# a certain limit
	weapon_vflip(prev_angle, angle)
	
	# Check if laser needs to be played and shoot animation needs to be sent out
	check_shoot(delta)

func weapon_vflip(prev_angle, angle):
	if (rotation_degrees >= -90 and rotation_degrees <= 90):
		weapon_sprite.flip_v = false
		$Shoot.flip_v = false
	else:
		weapon_sprite.flip_v = true
		$Shoot.flip_v = true
	
	prev_angle = angle * 180 / PI
	
func check_shoot(delta):
	# TODO add a shoot limit to how fast you can click the shoot button
	if (Input.is_action_just_pressed("Left Click") && (weapon_energy) > 0):
		weapon_energy -= 10
		
		animation_player.play("Shoot")
		Laser.play()
		
		var weapon_direction: Vector2 = (global_position).normalized()
		var weapon_scale: float = scale.x 
		
		var projectile = projectile_scene.instantiate()
		add_child(projectile)
		
		var projectile_node: Node2D = get_node("Projectile")
		projectile_node.process_moving_laser(weapon_scale)
