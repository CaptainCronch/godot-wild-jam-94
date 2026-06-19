extends CharacterBody2D
class_name Disc

const BASE_SPEED := 250.0
const SPIN_SPEED := 2.0
const LIFETIME := 30.0

@export var sprite: Polygon2D
@export var shadow: ShadowComponent
@export var hurtbox: HurtBoxComponent

var height := 0.0
var angle := 0.0
var timer := 0.0


func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(angle) * BASE_SPEED
	
	set_collision_mask_value(1, height > Global.TILE_HEIGHT)
	set_collision_mask_value(2, height > Global.TILE_HEIGHT * 2)
	set_collision_mask_value(3, height > Global.TILE_HEIGHT * 3)
	
	await get_tree().create_timer(0.5).timeout
	hurtbox.set_collision_mask_value(5, true)


func _process(delta: float) -> void:
	sprite.rotate(SPIN_SPEED * delta * sign(velocity.x))
	timer += delta
	if timer >= LIFETIME:
		queue_free()


func _physics_process(delta: float) -> void:
	#if is_on_wall(): queue_free()
	var result := move_and_collide(velocity * delta)
	if is_instance_valid(result):
		#velocity = Vector2.from_angle(result.get_angle()) * BASE_SPEEDs
		velocity = velocity.reflect(Vector2.from_angle(result.get_angle()))
		hurtbox.attack.attack_direction = hurtbox.attack.attack_direction.reflect(Vector2.from_angle(result.get_angle()))
		#bounces += 1
		#if bounces >= MAX_BOUNCES:
			#queue_free()
