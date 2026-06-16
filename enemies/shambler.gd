extends CharacterBody2D
class_name Shambler

@export var plat_comp: PlatformerComponent


func _process(_delta: float) -> void:
	plat_comp.dir = global_position.direction_to(Global.player.global_position)
