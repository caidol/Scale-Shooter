extends Area2D

var laser_speed = 1200.0
var laser_travelling: bool = false
var scale_value = null
@onready var laser_node: Area2D = $"."
@onready var destroy_timer: Timer = $Timers/DestroyTimer
@onready var laser_animation: AnimationPlayer = $AnimationPlayer
@onready var laser_direction = Vector2.RIGHT

signal laser_has_collided(body)

func _process(delta):
	# In case of the destroy timer stopping, we free the laser from the 
	# queue.
	
	if (laser_direction != null && scale_value != null):
		position += laser_direction * (laser_speed / scale_value) * delta

	if !(destroy_timer.time_left > 0):
		laser_node.queue_free()

func _on_body_entered(body):
	laser_direction = null 
	scale_value = null
	laser_has_collided.emit(body)
	laser_node.queue_free()

#func _on_weapon_laser_appears(delta, direction):
func process_moving_laser(weapon_scale: float):
	# Start the destroy timer
	destroy_timer.start()
	
	# Play laser_animation
	laser_animation.play("LaserShoot")
	scale_value = weapon_scale

func _on_laser_has_collided(body):
	var collision_node = get_tree().get_root().get_node("BaseScene").get_node(str(body.name))
	print("COLLISION NODE: ", collision_node)	

	if (
		(collision_node.name).substr(0, 5) == "Slime"
		|| (collision_node.name).substr(0, 5) == "Drone"
	):
		collision_node.health -= 20
