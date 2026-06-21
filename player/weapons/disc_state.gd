extends State

const DISC := preload("uid://csu51ow423c4m")
const HEIGHT_OFFSET := -10.0
const SELF_KNOCKBACK := -50.0
#const MAX_AMMO := 6
const RELOAD_TIME := 1.0

var reload_timer := 0.0
var girth_upgrade := false
var double_upgrade := false
var bar: TextureProgressBar

@export var player: Player
@export var weapon: Weapon
@export var muzzle: Marker2D
@export var animator: AnimationPlayer


func enter() -> void:
	bar = Global.ui.disc_bar
	reload_timer = 0.0
	player.reloading = false
	bar.show()
	play_animation("disc_in")


func exit() -> void:
	player.reloading = false
	bar.hide()
	play_animation("disc_out")


func update(delta: float) -> void:
	if reload_timer > 0.0:
		reload_timer -= delta
		play_animation("disc_reloading", false)
	else:
		player.reloading = false
	
	bar.value = remap(reload_timer, 1.0, 0.0, 0.0, 8.0)


func fire() -> void:
	if reload_timer > 0.0: return
	play_animation("disc_fire")
	var disc: Disc = DISC.instantiate()
	disc.height = player.plat_comp.position_z
	disc.global_position = muzzle.global_position
	disc.angle = weapon.rotation
	
	disc.shadow.height = player.plat_comp.floor_height
	disc.shadow.blob.position.y = player.plat_comp.floor_height
	
	disc.sprite.rotation = weapon.rotation
	disc.sprite.position.y = player.plat_comp.position_z + HEIGHT_OFFSET
	
	disc.hurtbox.attack.attack_direction = Vector2.RIGHT.rotated(weapon.rotation)
	disc.hurtbox.attack.height = player.plat_comp.position_z
	
	disc.self_damaging = not double_upgrade
	disc.girth = girth_upgrade
	if girth_upgrade: disc.hurtbox.attack.size *= 2
	get_tree().current_scene.add_child(disc)
	
	player.velocity += Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK
	#player.camera_holder.shake(0.2)
	player.camera_holder.kick(Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK)
	
	reload_timer = RELOAD_TIME * (0.5 if double_upgrade else 1.0)
	player.reloading = true
	
	$"../../Muzzle/Disc".play()


func fire_hold() -> void:
	fire()


func fire_release() -> void: pass


func play_animation(animation: String, interrupt := true) -> void:
	if not animator.current_animation == animation:
		if not interrupt and animator.is_playing(): return
		animator.play("RESET")
		animator.advance(0)
		animator.play(animation)
