extends State

const GRENADE := preload("uid://bdvwmcxr5eox6")
const HEIGHT_OFFSET := -10.0
const SELF_KNOCKBACK := -100.0
#const MAX_AMMO := 6
#const FIRE_DELAY := 1.5
const FUSE_MAX := 1.0

#var ammo := MAX_AMMO
#var delay_timer := 0.0
var ui_info := fuse_timer
var fuse_timer := FUSE_MAX
var charging := false
var reloading := false
var damage_upgrade := false
var self_damage_upgrade := false
var bar: TextureProgressBar

@export var player: Player
@export var weapon: Weapon
@export var muzzle: Marker2D
#@export var muzzle_flash: Polygon2D
@export var animator: AnimationPlayer


func enter() -> void:
	bar = Global.ui.fuse_bar
	ui_info = fuse_timer
	fuse_timer = FUSE_MAX
	charging = false
	reloading = false
	player.reloading = false
	bar.show()
	play_animation("launcher_in")


func exit() -> void:
	player.reloading = false
	bar.hide()
	play_animation("launcher_out")


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
	
	bar.value = remap(fuse_timer, 0.0, 1.0, 0.25, 1.0)


func fire() -> void:
	if reloading: return
	charging = true


func fire_hold() -> void:
	play_animation("launcher_reloading")
	if fuse_timer <= 0.0: shoot()
	if reloading: return
	charging = true


func fire_release() -> void:
	if not charging or reloading: return
	shoot()


func shoot() -> void:
	#if delay_timer > 0.0: return
	play_animation("launcher_fire")
	charging = false
	
	var grenade: Grenade = GRENADE.instantiate()
	grenade.height = player.plat_comp.position_z
	grenade.global_position = muzzle.global_position
	grenade.angle = weapon.rotation
	
	grenade.shadow.height = player.plat_comp.floor_height
	grenade.shadow.blob.position.y = player.plat_comp.floor_height
	
	grenade.sprite.rotation = weapon.rotation
	grenade.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	grenade.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(weapon.rotation)
	grenade.hurtbox.attack.height = player.plat_comp.position_z
	
	grenade.damage_upgrade = damage_upgrade
	grenade.self_damage_upgrade = self_damage_upgrade
	
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


func play_animation(animation: String, interrupt := true) -> void:
	if not animator.current_animation == animation:
		if not interrupt and animator.is_playing(): return
		animator.play("RESET")
		animator.advance(0)
		animator.play(animation)
