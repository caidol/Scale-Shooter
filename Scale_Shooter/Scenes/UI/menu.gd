extends Control
var level = preload("res://Scale_Shooter/Scenes/Levels/base_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_pressed():
	get_tree().change_scene_to_packed(level)

func _on_quit_pressed():
	get_tree().quit()
