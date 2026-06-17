extends TileMapLayer
class_name WorldLayer

@export var height := 0
@export var brightness_base := 0.75
@export var brightness_step := 0.15


func _ready() -> void:
	Global.tilemaps.append(self)
	
	#z_index = height - 1
	
	#var brightness := brightness_base + ((height - 1) * brightness_step)
	#brightness = clampf(brightness, 0.0, 2.0)
	#modulate = Color(brightness, brightness, brightness)


#func _use_tile_data_runtime_update(layer: int, coords: Vector2i) -> bool:
	#return true
