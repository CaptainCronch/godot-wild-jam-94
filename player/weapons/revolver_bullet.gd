extends CharacterBody2D
class_name RevolverBullet

const BASE_SPEED := 1000.0
const MAX_PIERCE := 2

@export var sprite: Polygon2D
@export var shadow: ShadowComponent
@export var hurtbox: HurtBoxComponent

var height := 0.0
var angle := 0.0
var pierced := 0


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(angle) * BASE_SPEED
	
	set_collision_mask_value(1, height > Global.TILE_HEIGHT)
	set_collision_mask_value(2, height > Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, height > Global.TILE_HEIGHT * 3)
	
	#occlusion.height = height


func _physics_process(delta: float) -> void:
	#if is_on_wall(): queue_free()
	if is_instance_valid(move_and_collide(velocity * delta)):
		queue_free()


func _on_hurtbox_component_hit(_hitbox: HitboxComponent) -> void:
	pierced += 1
	if pierced >= MAX_PIERCE:
		queue_free()
