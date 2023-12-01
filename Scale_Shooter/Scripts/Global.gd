extends Node

@onready var tree: SceneTree = get_tree()
@onready var root: Window = get_tree().get_root()
var gravity: int = 2500

# All the four fixed axis directions
const RIGHT = Vector2.RIGHT
const LEFT = Vector2.LEFT
const UP = Vector2.UP
const DOWN = Vector2.DOWN
