extends Node2D

var ending: PackedScene = preload("res://Scale_Shooter/Scenes/UI/ending.tscn")

func _on_area_2d_body_entered(body):
	get_tree().change_scene_to_packed(ending)
