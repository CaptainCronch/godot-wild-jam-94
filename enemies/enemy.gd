extends CharacterBody2D
class_name Enemy

const SEPARATION_SPEED := 5000.0
const MAX_SEPARATION := 2
const AI_UPDATE := 0.3

@export var plat_comp: PlatformerComponent
@export var enemy_check: Area2D
@export var sprite: Polygon2D

var _player_follow_factor := 1.0
var _separation_factor := 1.0
var current_speed := SEPARATION_SPEED
var player_dir := Vector2()
var separate_dir := Vector2()
var desired := Vector2()
var disable_player_dir := false
var ai_timer := 0.0


func _ready() -> void:
	current_speed = SEPARATION_SPEED


func _process(delta: float) -> void:
	ai_timer += delta


func _physics_process(_delta: float) -> void:
	if ai_timer < AI_UPDATE: separate()


func separate() -> void:
	ai_timer = 0.0
	player_dir = global_position.direction_to(Global.player.global_position)
	separate_dir = Vector2()
	var i := 0
	for enemy in enemy_check.get_overlapping_areas():
		if enemy is HitboxComponent:
			if global_position.distance_squared_to(enemy.global_position) == 0.0: continue
			if i > MAX_SEPARATION: break
			separate_dir += enemy.global_position.direction_to(global_position) / global_position.distance_to(enemy.global_position) * _separation_factor
	separate_dir = separate_dir.normalized()
	desired = ((player_dir * _player_follow_factor * (0.0 if disable_player_dir else 1.0)) + separate_dir).normalized()
	plat_comp.dir = desired


func _on_damage_taken(_attack: Attack) -> void:
	Global.player.camera_holder.shake(0.01)
	(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	(sprite.material as ShaderMaterial).set_shader_parameter("active", false)
