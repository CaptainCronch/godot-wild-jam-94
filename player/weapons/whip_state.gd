extends State

const FIRE_DELAY := 0.6
const SELF_KNOCKBACK := 25.0

@export var player: Player
@export var weapon: Weapon
@export var sourspot: HurtBoxComponent
@export var sweetspot: HurtBoxComponent
@export var whip: AnimatedSprite2D
@export var animator: AnimationPlayer

var fire_timer := 0.0
var ui_info := fire_timer
var double_upgrade := false


func enter() -> void:
	fire_timer = 0.0
	ui_info = fire_timer
	play_animation("whip_in")


func exit() -> void:
	play_animation("whip_out")


func update(delta: float) -> void:
	if fire_timer < FIRE_DELAY * (0.5 if double_upgrade else 1.0): fire_timer += delta
	ui_info = fire_timer


func fire() -> void:
	pass


func fire_hold() -> void:
	if fire_timer < FIRE_DELAY * (0.5 if double_upgrade else 1.0): return
	fire_timer = 0.0
	play_animation("whip_fire")
	$"../../Muzzle/Shot".play()
	
	sourspot.attack.height = player.plat_comp.position_z
	sweetspot.attack.height = player.plat_comp.position_z
	sourspot.attack.attack_direction = Vector2.from_angle(weapon.rotation)
	sweetspot.attack.attack_direction = Vector2.from_angle(weapon.rotation)
	sourspot.check_collision()
	sweetspot.check_collision()
	
	player.velocity += Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK
	player.camera_holder.kick(Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK)
	
	whip.play("default")


func fire_release() -> void: pass


func play_animation(animation: String, interrupt := true) -> void:
	if not animator.current_animation == animation:
		if not interrupt and animator.is_playing(): return
		animator.play("RESET")
		animator.advance(0)
		animator.play(animation)
	elif interrupt:
		animator.play("RESET")
		animator.advance(0)
		animator.play(animation)


func _on_sourspot_hit(_hitbox: HitboxComponent) -> void:
	pass # Replace with function body.


func _on_sweetspot_hit(_hitbox: HitboxComponent) -> void:
	if fire_timer < (FIRE_DELAY * (0.5 if double_upgrade else 1.0)) / 2.0: fire_timer += (FIRE_DELAY * (0.5 if double_upgrade else 1.0)) / 2.0
