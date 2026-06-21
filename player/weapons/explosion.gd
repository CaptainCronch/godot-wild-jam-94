extends Node2D
class_name Explosion

const SELF_DESTRUCT_AUDIO := preload("uid://brs8j5ij13tuu")

const RADIUS := 64.0

@export var big_stream: AudioStream
@export var little_stream: AudioStream
@export var hurtbox: HurtBoxComponent
@export var sprite: AnimatedSprite2D

var height := 0.0


func _ready() -> void:
	Global.player.camera_holder.shake(0.3)
	$HurtboxComponent/CollisionShape2D.shape.radius = RADIUS
	#sprite.polygon = Global.generate_circle_polygon(RADIUS, 32)
	hurtbox.attack.height = height
	#sprite.position.y = height
	var sound: AudioStreamPlayer2D = SELF_DESTRUCT_AUDIO.instantiate()
	sound.global_position = global_position
	sound.stream = big_stream if hurtbox.attack.player_damage == 1 else little_stream
	get_tree().current_scene.add_child(sound)
	sound.play()
	await get_tree().physics_frame
	hurtbox.check_collision()
	#sprite.color = Color.WHITE
	#await get_tree().create_timer(0.05).timeout
	#sprite.color = Color.ORANGE_RED
	#await get_tree().create_timer(0.05).timeout
	#sprite.color = Color.ORANGE
	await $AnimatedSprite2D.animation_finished
	queue_free()
