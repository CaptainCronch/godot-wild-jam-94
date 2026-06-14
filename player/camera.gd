extends Node2D

@export var camera: Camera2D


func _process(_delta: float) -> void:
	camera.position = Vector2()
