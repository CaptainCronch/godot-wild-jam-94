extends Node2D
class_name Weapon

const REVOLVER_BULLET := preload("uid://bgraey60p2frl")
const HEIGHT_OFFSET := -20.0
const KNOCKBACK := 50.0

@export var player: Player
@export var polygon: Polygon2D
@export var muzzle: Marker2D


func fire() -> void:
	var bullet := REVOLVER_BULLET.instantiate()
	bullet.height = player.position_z
	bullet.global_position = muzzle.global_position
	bullet.angle = rotation
	bullet.sprite.rotation = rotation
	bullet.sprite.position.y = player.position_z + HEIGHT_OFFSET
	get_tree().current_scene.add_child(bullet)
	
	player.velocity += Vector2.RIGHT.rotated(rotation) * KNOCKBACK * -1
