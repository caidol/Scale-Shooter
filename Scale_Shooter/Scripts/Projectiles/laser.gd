extends CharacterBody2D

var laser_speed = 500.0
@onready var laser_node: Node2D = $"."
@onready var destroy_timer: Timer = $Timers/DestroyTimer
@onready var laser_animation: AnimationPlayer = $AnimationPlayer

signal laser_has_collided

func _ready():
	print_debug(laser_animation)
	laser_animation.play("LaserShoot")

func _process(delta):
	# In case of the destroy timer stopping, we free the laser from the 
	# queue.
	
	# test
	laser_animation.play("LaserShoot")
	
	if (destroy_timer.is_stopped()):
		laser_node.queue_free()	

func _on_collision_area_body_entered(body):
	laser_node.queue_free()
	laser_has_collided.emit(body)

func _on_weapon_laser_appears(delta, direction):
	# Receive the direction that the laser needs to be shot at relative to
	# the direction that the weapon is pointing towards
	
	# Play laser_animation
	laser_animation.play("LaserShoot")
	
	# update position
	position += direction * laser_speed * delta
