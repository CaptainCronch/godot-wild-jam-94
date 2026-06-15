extends Node2D
class_name CameraHolder

@export var camera: Camera2D


func _process(_delta: float) -> void:
	camera.position = Vector2()
