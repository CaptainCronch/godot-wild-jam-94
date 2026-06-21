extends CharacterBody2D
class_name Disc

const BASE_SPEED := 250.0
#const SPIN_SPEED := 2.0
const LIFETIME := 10.0

@export var sprite: AnimatedSprite2D
@export var shadow: ShadowComponent
@export var hurtbox: HurtBoxComponent
@export var hitbox: HitboxComponent

var height := 0.0
var angle := 0.0
var timer := 0.0
var girth := false
var self_damaging := true
var first_hit := false


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(angle) * BASE_SPEED
	#$Polygon2D2.rotation = hurtbox.attack.attack_direction.angle()
	
	set_collision_mask_value(1, height > Global.TILE_HEIGHT)
	set_collision_mask_value(2, height > Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, height > Global.TILE_HEIGHT * 3)
	
	hitbox.height = height
	
	if self_damaging:
		await get_tree().create_timer(0.5).timeout
		hurtbox.set_collision_mask_value(5, true)


func _process(delta: float) -> void:
	#$Polygon2D2.rotation = hurtbox.attack.attack_direction.angle()
	#sprite.rotate(SPIN_SPEED * delta * sign(velocity.x))
	timer += delta
	if timer >= LIFETIME:
		queue_free()


func _physics_process(delta: float) -> void:
	#if is_on_wall(): queue_free()
	var result := move_and_collide(velocity * delta)
	if is_instance_valid(result) and result.get_collider() is TileMapLayer:
		#print(result.get_collider())
		#velocity = Vector2.from_angle(result.get_angle()) * BASE_SPEEDs
		velocity = velocity.reflect(Vector2.from_angle(result.get_angle()))
		hurtbox.attack.attack_direction = velocity.normalized()
		#bounces += 1
		#if bounces >= MAX_BOUNCES:
			#queue_free()


func _on_hitbox_hit(attack: Attack) -> void:
	velocity = attack.attack_direction * BASE_SPEED * 1.5
	hurtbox.attack.attack_direction = velocity.normalized()
	hurtbox.attack.attack_damage = 5
	hurtbox.attack.knockback_force = 250.0
	hurtbox.attack.knockup_force = -1.5
	hurtbox.attack.stun_time = 0.2
	#timer = 0.0
	first_hit = false


func _on_hurtbox_hit(_hitbox: HitboxComponent) -> void:
	if not first_hit and girth:
		velocity *= 0.5
		first_hit = true
