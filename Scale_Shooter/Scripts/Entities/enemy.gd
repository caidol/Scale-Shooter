extends CharacterBody2D

# ENEMIES STATES:
#
# The two enemies of the game (drone and slime) will both extend from this enemy script
# All enemies have three states, however two of these states work together
#
# -> IDLE: The enemy is still in position and is not moving
# -> TARGET: Upon the player entering a given range around the enemy, it will target them
#			 by moving towards their direction.
#
# -> MOVING: The enemy will move in a continous direction unless experiencing a collision
#            with an object or reaching the end of a platform etc.

var tree: SceneTree = Global.tree
var root: Window = Global.root

@export var base_health: int = 100
@export var base_speed: int = 250
@export var target_range: float = 300.0

@onready var target = get_tree().get_root().get_node("BaseScene").get_node("Player")

func vector_direction_to_player(enemy_x, enemy_y, target_x, target_y):
	# Return a normalised vector that points the exact direction that the player is located at
	# away from the enemy

	return Vector2(target_x - enemy_x, target_y - enemy_y).normalized()
