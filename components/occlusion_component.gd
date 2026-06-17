extends Area2D
class_name OcclusionComponent

@export var transparency := 0.3
@export var target: Node2D


func _physics_process(_delta: float) -> void:
	if has_overlapping_bodies():
		#for target in targets:
			target.modulate = Color(1.0, 1.0, 1.0, transparency)
	else:
		#for target in targets:
			target.modulate = Color(1.0, 1.0, 1.0, 1.0)
