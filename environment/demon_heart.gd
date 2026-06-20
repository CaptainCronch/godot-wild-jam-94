extends CharacterBody2D
class_name DemonHeart

@export var sprite: Polygon2D
@export var health_comp: HealthComponent
@export var plat_comp: PlatformerComponent
@export var health_label: Label


func _ready() -> void:
	health_comp.max_health = randi_range(5, 15)
	health_comp.health = health_comp.max_health
	health_label.text = str(health_comp.health)


func _physics_process(_delta: float) -> void:
	pass


func flash() -> void:
	health_comp.damage(Attack.new(1))
	health_label.text = str(health_comp.health)
	Global.player.camera_holder.shake(0.01)
	(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	(sprite.material as ShaderMaterial).set_shader_parameter("active", false)


func _on_damage_taken(attack: Attack) -> void:
	if attack.attack_direction != Vector2.ZERO:
		flash()


func _on_bounced() -> void:
	flash()


func _on_death(_attack: Attack) -> void:
	Global.world.collected_heart()
	queue_free()
