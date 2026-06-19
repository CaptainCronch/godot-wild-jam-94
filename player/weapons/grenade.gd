extends CharacterBody2D
class_name Grenade

const EXPLOSION := preload("uid://cono4p61cs4he")

const BASE_SPEED := 1500.0
const SLOW_RATE := 5.0

@export var sprite: Polygon2D
@export var shadow: ShadowComponent
@export var hurtbox: HurtBoxComponent

var height := 0.0
var angle := 0.0
var fuse := 1.0
var exploded := false


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(angle) * BASE_SPEED
	
	set_collision_mask_value(1, height > Global.TILE_HEIGHT)
	set_collision_mask_value(2, height > Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, height > Global.TILE_HEIGHT * 3)
	
	#occlusion.height = height


func _physics_process(delta: float) -> void:
	fuse -= delta
	if fuse <= 0.0:
		explode()
	
	#if is_on_wall(): queue_free()
	#velocity -= velocity.normalized() * SLOW_RATE * delta
	velocity = Global.decay_towards_vec2(velocity, Vector2.ZERO, SLOW_RATE, delta)
	
	if is_instance_valid(move_and_collide(velocity * delta)):
		explode()


func explode() -> void:
	if exploded: return
	exploded = true
	var explosion: Explosion = EXPLOSION.instantiate()
	explosion.global_position = global_position
	explosion.height = height
	explosion.sprite.position.y = height
	get_tree().current_scene.add_child(explosion)
	queue_free()


#func _on_hurtboxa _component_hit(_hitbox: HitboxComponent) -> void:
	#explode()
