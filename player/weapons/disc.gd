extends CharacterBody2D
class_name Disc

const BASE_SPEED := 500.0
const SPIN_SPEED := 2.0
const MAX_BOUNCES := 5

@export var sprite: Polygon2D
@export var shadow: ShadowComponent
@export var hurtbox: HurtBoxComponent

var height := 0.0
var angle := 0.0
var bounces := 0


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(angle) * BASE_SPEED
	
	set_collision_mask_value(1, height > Global.TILE_HEIGHT)
	set_collision_mask_value(2, height > Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, height > Global.TILE_HEIGHT * 3)
	
	await get_tree().create_timer(0.1).timeout
	hurtbox.set_collision_mask_value(5, true)


func _process(delta: float) -> void:
	sprite.rotate(SPIN_SPEED * delta)


func _physics_process(delta: float) -> void:
	#if is_on_wall(): queue_free()
	var result := move_and_collide(velocity * delta)
	if is_instance_valid(result):
		#velocity = Vector2.from_angle(result.get_angle()) * BASE_SPEEDs
		velocity = velocity.reflect(Vector2.from_angle(result.get_angle()))
		bounces += 1
		if bounces >= MAX_BOUNCES:
			queue_free()
