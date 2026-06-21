extends CharacterBody2D
class_name Enemy

const BLOOD = preload("uid://dn5dtcu0dbhp6")
const CORPSE = preload("uid://d0qauj3amib7m")

const SEPARATION_SPEED := 5000.0
const MAX_SEPARATION := 2
const AI_UPDATE := 1.0

@export var color: Color

@export var plat_comp: PlatformerComponent
@export var health_comp: HealthComponent
@export var enemy_check: Area2D
@export var sprite: Polygon2D
@export var shadow: ShadowComponent

var _player_follow_factor := 1.0
var _separation_factor := 1.0
var current_speed := SEPARATION_SPEED
var player_dir := Vector2()
var separate_dir := Vector2()
var desired := Vector2()
var disable_player_dir := false
var ai_timer := 0.0


func _ready() -> void:
	health_comp.death.connect(_on_death)
	current_speed = SEPARATION_SPEED
	reset_physics_interpolation()
	#if randf_range(0.0, 1.0) <= giant_chance:
		#sprite.scale *= 3.0


func _process(delta: float) -> void:
	ai_timer += delta


func _physics_process(_delta: float) -> void:
	if ai_timer < AI_UPDATE: separate()


func separate() -> void:
	ai_timer = 0.0
	player_dir = global_position.direction_to(Global.player.global_position) if is_instance_valid(Global.player) else Vector2.ZERO
	separate_dir = Vector2()
	var i := 0
	for enemy in enemy_check.get_overlapping_areas():
		if enemy is HitboxComponent:
			if is_zero_approx(global_position.distance_squared_to(enemy.global_position)): continue
			if i > MAX_SEPARATION: break
			separate_dir += enemy.global_position.direction_to(global_position) / global_position.distance_to(enemy.global_position) * _separation_factor
			i += 1
	separate_dir = separate_dir.normalized()
	desired = ((player_dir * _player_follow_factor * (0.0 if disable_player_dir else 1.0)) + separate_dir).normalized()
	plat_comp.dir = desired


func _on_damage_taken(_attack: Attack) -> void:
	Global.player.camera_holder.shake(0.01)
	(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	(sprite.material as ShaderMaterial).set_shader_parameter("active", false)


func _on_death(attack: Attack) -> void:
	var blood: CPUParticles2D = BLOOD.instantiate()
	blood.global_position = global_position
	blood.position.y += plat_comp.position_z + -20.0
	blood.direction = attack.attack_direction
	blood.modulate = color
	get_tree().current_scene.add_child(blood)
	
	var corpse: Node2D = CORPSE.instantiate()
	corpse.global_position = global_position
	corpse.position.y += plat_comp.floor_height
	corpse.rotation = velocity.angle()
	corpse.modulate = color
	Global.corpse_group.add_child(corpse)
	
	queue_free()
