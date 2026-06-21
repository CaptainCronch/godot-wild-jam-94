extends State

const BULLET := preload("uid://bgraey60p2frl")
const HEIGHT_OFFSET := -10.0
const SELF_KNOCKBACK := -25.0
const MAX_AMMO := 6
const RELOAD_TIME := 1.0
const FIRE_DELAY := 0.05

var ammo := MAX_AMMO
var ui_info := ammo
var reload_timer := RELOAD_TIME * (0.5 if uzi_upgrade else 1.0)
var delay_timer := 0.0
var uzi_upgrade := false
var pierce_upgrade := true

@export var player: Player
@export var weapon: Weapon
@export var muzzle: Marker2D
@export var muzzle_flash: Polygon2D


func enter() -> void:
	ammo = MAX_AMMO
	ui_info = ammo
	reload_timer = RELOAD_TIME * (0.5 if uzi_upgrade else 1.0)
	delay_timer = FIRE_DELAY
	player.reloading = false


func exit() -> void:
	player.reloading = false


func update(delta: float) -> void:
	if reload_timer > 0.0:
		reload_timer -= delta
	else:
		ammo = MAX_AMMO
		player.reloading = false
	
	if delay_timer > 0.0:
		delay_timer -= delta
	
	ui_info = ammo


func fire() -> void:
	if uzi_upgrade: return
	shoot()


func fire_hold() -> void:
	if not uzi_upgrade or delay_timer > 0.0: return
	shoot()


func shoot() -> void:
	if ammo <= 0: return
	ammo -= 1
	var bullet: RevolverBullet = BULLET.instantiate()
	bullet.height = player.plat_comp.position_z
	bullet.global_position = muzzle.global_position
	bullet.angle = weapon.rotation
	
	bullet.shadow.height = player.plat_comp.floor_height
	bullet.shadow.blob.position.y = player.plat_comp.floor_height
	
	bullet.sprite.rotation = weapon.rotation
	bullet.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	bullet.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(weapon.rotation)
	bullet.hurtbox.attack.height = player.plat_comp.position_z
	
	if pierce_upgrade: bullet.pierce_bonus = 2
	get_tree().current_scene.add_child(bullet)
	
	player.velocity += Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK
	player.camera_holder.kick(Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK)
	
	reload_timer = RELOAD_TIME * (0.5 if uzi_upgrade else 1.0)
	delay_timer = FIRE_DELAY
	
	muzzle_flash.show()
	await get_tree().create_timer(0.05).timeout
	muzzle_flash.hide()
	
	if ammo <= 0:
		player.reloading = true


func fire_release() -> void: pass
