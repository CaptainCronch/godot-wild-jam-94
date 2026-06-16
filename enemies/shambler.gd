extends CharacterBody2D
class_name Shambler

@export var platformer_comp: PlatformerComponent


func _process(_delta: float) -> void:
	platformer_comp.dir = global_position.direction_to(Global.player.global_position)
