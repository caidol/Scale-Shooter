extends Area2D

var laser_speed = 200.0
var laser_travelling: bool = false
@onready var laser_direction = Vector2.RIGHT
@onready var laser_node: Area2D = $"."
@onready var destroy_timer: Timer = $Timers/DestroyTimer
@onready var laser_animation: AnimationPlayer = $AnimationPlayer

signal laser_has_collided(body)

func _process(delta):
	# In case of the destroy timer stopping, we free the laser from the 
	# queue.
	
	position += laser_direction * laser_speed * delta

func _on_weapon_laser_appears(delta, direction):
	# Receive the direction that the laser needs to be shot at relative to
	# the direction that the weapon is pointing towards
	print("Hello")	
		
	# Play laser_animation
	laser_animation.play("LaserShoot")
	laser_direction = direction

func _on_body_entered(body):
	laser_direction = null  
	laser_node.queue_free()
	laser_has_collided.emit(body)
