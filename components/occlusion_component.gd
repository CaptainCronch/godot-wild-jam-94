extends Area2D
class_name OcclusionComponent

@export var transparency := 0.3
@export var entity := false
@export var target: Node2D

var height := 0.0
var floor_height := 0.0

@onready var height_check: Area2D = $HeightCheck


func _process(_delta: float) -> void:
	position.y = floor_height
	height_check.position.y = height


func _physics_process(_delta: float) -> void:
	if monitoring and height_check.has_overlapping_bodies():
		#for target in targets:
		#if target.global_position.y < (snappedf(global_position.y, 128.0)) + 64.0:
		if has_overlapping_bodies():
			if entity:
				(target.material as ShaderMaterial).set_shader_parameter("transparency", transparency)
			else:
				target.modulate = Color(1.0, 1.0, 1.0, transparency)
			return
	
	if entity:
		(target.material as ShaderMaterial).set_shader_parameter("transparency", 1.0)
	else:
		target.modulate = Color(1.0, 1.0, 1.0, 1.0)
