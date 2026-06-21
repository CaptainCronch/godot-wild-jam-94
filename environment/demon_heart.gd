extends CharacterBody2D
class_name DemonHeart

const MARGIN := Vector2(64.0, 64.0)

@export var sprite: AnimatedSprite2D
@export var health_comp: HealthComponent
@export var plat_comp: PlatformerComponent
@export var health_label: Label
@export var shadow: ShadowComponent
@export var screen_notifier: VisibleOnScreenNotifier2D
@export var pointer: Node2D
@export var pointer_arrow: Sprite2D

var flash_tween: Tween


func _ready() -> void:
	health_comp.max_health = randi_range(5, 10)
	health_comp.health = health_comp.max_health
	health_label.text = str(health_comp.health)
	(sprite.material as ShaderMaterial).set_shader_parameter("active", false)
	reset_physics_interpolation()


func _process(_delta: float) -> void:
	var cam_pos := Global.player.camera.global_position
	var cam_rect := Global.player.camera.get_viewport_rect()
	pointer.global_position = (global_position + Vector2(0.0, plat_comp.floor_height)).clamp(cam_pos - ((cam_rect.size/2) - MARGIN), cam_pos + ((cam_rect.size/2) - MARGIN))
	pointer_arrow.look_at(global_position)

func flash() -> void:
	health_comp.damage(Attack.new(1))
	health_label.text = str(health_comp.health)
	Global.player.camera_holder.shake(0.01)
	
	if is_instance_valid(flash_tween): flash_tween.kill()
	flash_tween = create_tween()
	flash_tween.tween_callback(func():
		(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
	)
	flash_tween.tween_interval(0.1)
	flash_tween.tween_callback(func():
		(sprite.material as ShaderMaterial).set_shader_parameter("active", false)
	)


func _on_damage_taken(attack: Attack) -> void:
	if attack.attack_direction != Vector2.ZERO:
		flash()


func _on_bounced() -> void:
	flash()


func _on_death(_attack: Attack) -> void:
	Global.world.collected_heart()
	queue_free()


func _on_screen_entered() -> void:
	pointer.hide()


func _on_screen_exited() -> void:
	pointer.show()
