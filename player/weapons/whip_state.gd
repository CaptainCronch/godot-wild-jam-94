extends State

const FIRE_DELAY := 0.5
const SELF_KNOCKBACK := 50.0

@export var player: Player
@export var weapon: Weapon
@export var sourspot: HurtBoxComponent
@export var sweetspot: HurtBoxComponent
@export var whip: Polygon2D

var fire_timer := 0.0
var ui_info := fire_timer


func enter() -> void:
	fire_timer = 0.0
	ui_info = fire_timer


func update(delta: float) -> void:
	if fire_timer < FIRE_DELAY: fire_timer += delta
	ui_info = fire_timer


func fire() -> void:
	if fire_timer < FIRE_DELAY: return
	fire_timer = 0.0
	
	sourspot.attack.height = player.plat_comp.position_z
	sweetspot.attack.height = player.plat_comp.position_z
	sourspot.attack.attack_direction = Vector2.from_angle(weapon.rotation)
	sweetspot.attack.attack_direction = Vector2.from_angle(weapon.rotation)
	sourspot.check_collision()
	sweetspot.check_collision()
	
	player.velocity += Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK
	player.camera_holder.kick(Vector2.from_angle(weapon.rotation) * SELF_KNOCKBACK)
	
	whip.show()
	await get_tree().create_timer(0.05).timeout
	whip.hide()


func fire_hold() -> void: pass


func fire_release() -> void: pass


func _on_sourspot_hit(_hitbox: HitboxComponent) -> void:
	pass # Replace with function body.


func _on_sweetspot_hit(_hitbox: HitboxComponent) -> void:
	if fire_timer < FIRE_DELAY / 2.0: fire_timer += FIRE_DELAY / 2.0
