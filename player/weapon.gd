extends Node2D
class_name Weapon

const REVOLVER_BULLET := preload("uid://bgraey60p2frl")
const HEIGHT_OFFSET := -20.0
const KNOCKBACK := 50.0

@export var player: Player
@export var polygon: Polygon2D
@export var muzzle: Marker2D


func fire() -> void:
	var bullet: RevolverBullet = REVOLVER_BULLET.instantiate()
	bullet.height = player.plat_comp.position_z
	bullet.global_position = muzzle.global_position
	bullet.angle = rotation
	
	bullet.shadow.height = player.plat_comp.floor_height
	bullet.shadow.blob.position.y = -player.plat_comp.floor_height
	#for body in player.plat_comp.world_area.get_overlapping_bodies():
		#if body is TileMapLayer:
			#bullet.shadow.overlapping_bodies.append(body)
	
	bullet.sprite.rotation = rotation
	bullet.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	bullet.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(rotation)
	bullet.hurtbox.attack.height = player.plat_comp.position_z
	get_tree().current_scene.add_child(bullet)
	
	player.velocity += Vector2.RIGHT.rotated(rotation) * KNOCKBACK * -1
