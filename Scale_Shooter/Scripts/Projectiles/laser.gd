extends Node2D

var laser_speed = 500.0
@onready var laser_node: Node2D = $"."
@onready var destroy_timer: Timer = $Timers/DestroyTimer

signal laser_has_collided

func _ready():
	pass

func _process(delta):
	# In case of the destroy timer stopping, we free the laser from the 
	# queue.
	if (destroy_timer.is_stopped()):
		laser_node.queue_free()	

func _on_collision_area_body_entered(body):
	laser_node.queue_free()
	laser_has_collided.emit(body)

func shoot_laser(laser_direction: Vector2, delta):
	# Receive the direction that the laser needs to be shot at relative to
	# the direction that the weapon is pointing towards
	
	# update position
	position += laser_direction * laser_speed * delta
	
	# TODO: work on the rest
