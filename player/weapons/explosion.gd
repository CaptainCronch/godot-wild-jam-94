extends Node2D
class_name Explosion

const RADIUS := 100.0

@export var hurtbox: HurtBoxComponent
@export var sprite: Polygon2D

var height := 0.0


func _ready() -> void:
	Global.player.camera_holder.shake(0.3)
	$HurtboxComponent/CollisionShape2D.shape.radius = RADIUS
	sprite.polygon = Global.generate_circle_polygon(RADIUS, 64)
	hurtbox.attack.height = height
	#sprite.position.y = height
	await get_tree().physics_frame
	hurtbox.check_collision()
	sprite.color = Color.WHITE
	await get_tree().create_timer(0.05).timeout
	sprite.color = Color.ORANGE_RED
	await get_tree().create_timer(0.05).timeout
	sprite.color = Color.ORANGE
	queue_free()
