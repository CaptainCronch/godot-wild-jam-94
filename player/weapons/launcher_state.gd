extends State

const GRENADE := preload("uid://bdvwmcxr5eox6")
const HEIGHT_OFFSET := -20.0
const SELF_KNOCKBACK := -300.0
#const MAX_AMMO := 6
#const FIRE_DELAY := 1.5
const FUSE_MAX := 1.0

#var ammo := MAX_AMMO
#var delay_timer := 0.0
var ui_info := fuse_timer
var fuse_timer := FUSE_MAX
var charging := false
var reloading := false

@export var player: Player
@export var weapon: Weapon
@export var muzzle: Marker2D
#@export var muzzle_flash: Polygon2D


func update(delta: float) -> void:
	#if delay_timer > 0.0:
		#delay_timer -= delta
	#else:
		#player.reloading = false
	
	if charging and fuse_timer > 0.0:
		fuse_timer -= delta
	elif not charging and fuse_timer < FUSE_MAX:
		fuse_timer += delta
	elif fuse_timer >= FUSE_MAX:
		reloading = false
		player.reloading = false
	
	ui_info = fuse_timer


func fire() -> void:
	if reloading: return
	charging = true


func fire_hold() -> void:
	if fuse_timer <= 0.0: shoot()
	if reloading: return
	charging = true


func fire_release() -> void:
	if not charging or reloading: return
	shoot()


func shoot() -> void:
	#if delay_timer > 0.0: return
	charging = false
	
	var grenade: Grenade = GRENADE.instantiate()
	grenade.height = player.plat_comp.position_z
	grenade.global_position = muzzle.global_position
	grenade.angle = weapon.rotation
	
	grenade.shadow.height = player.plat_comp.floor_height
	grenade.shadow.blob.position.y = player.plat_comp.floor_height
	
	grenade.sprite.rotation = weapon.rotation
	grenade.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	#grenade.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(weapon.rotation)
	#grenade.hurtbox.attack.height = player.plat_comp.position_z
	
	get_tree().current_scene.add_child(grenade)
	grenade.fuse = maxf(fuse_timer, 0.01)
	
	player.velocity += Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK
	
	#player.camera_holder.shake(0.2)
	player.camera_holder.kick(Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK)
	
	#muzzle_flash.show()
	#await get_tree().create_timer(0.05).timeout
	#muzzle_flash.hide()
	
	fuse_timer = (fuse_timer * -1.0) + FUSE_MAX
	#delay_timer = FIRE_DELAY
	
	player.reloading = true
	reloading = true
