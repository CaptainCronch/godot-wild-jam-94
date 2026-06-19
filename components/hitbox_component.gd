extends Area2D
class_name HitboxComponent

@export var height := 0.0
@export var size := 0.0
@export var health_comp : HealthComponent


func _ready() -> void:
	if not collision_layer and not collision_mask:
		printerr("HitboxComponent of ", get_parent().name, " has no collision bits enabled!")


func damage(attack: Attack) -> void:
	if is_instance_valid(health_comp): health_comp.damage(attack)
