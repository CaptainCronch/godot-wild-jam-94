extends Node2D
class_name Weapon

const REVOLVER_BULLET := preload("uid://bgraey60p2frl")
const HEIGHT_OFFSET := -20.0
const REVOLVER_SELF_KNOCKBACK := -50.0
const REVOLVER_MAX_AMMO := 6
const REVOLVER_RELOAD_TIME := 1.5

var revolver_ammo := REVOLVER_MAX_AMMO
#var revolver_reload_timer := REVOLVER_RELOAD_TIME

@export var player: Player
@export var polygon: Polygon2D
@export var muzzle: Marker2D
@export var muzzle_flash: Polygon2D


func fire() -> void:
	if revolver_ammo <= 0: return
	revolver_ammo -= 1
	var bullet: RevolverBullet = REVOLVER_BULLET.instantiate()
	bullet.height = player.plat_comp.position_z
	bullet.global_position = muzzle.global_position
	bullet.angle = rotation
	
	bullet.shadow.height = player.plat_comp.floor_height
	bullet.shadow.blob.position.y = player.plat_comp.floor_height
	#for body in player.plat_comp.world_area.get_overlapping_bodies():
		#if body is TileMapLayer:
			#bullet.shadow.overlapping_bodies.append(body)
	
	bullet.sprite.rotation = rotation
	bullet.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	bullet.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(rotation)
	bullet.hurtbox.attack.height = player.plat_comp.position_z
	get_tree().current_scene.add_child(bullet)
	
	player.velocity += Vector2.from_angle(rotation) * REVOLVER_SELF_KNOCKBACK
	
	#player.camera_holder.shake(0.2)
	player.camera_holder.kick(Vector2.from_angle(rotation) * -100.0)
	
	muzzle_flash.show()
	await get_tree().create_timer(0.05).timeout
	muzzle_flash.hide()
	
	if revolver_ammo <= 0:
		player.reloading = true
		await get_tree().create_timer(REVOLVER_RELOAD_TIME).timeout
		revolver_ammo = REVOLVER_MAX_AMMO
		player.reloading = false
