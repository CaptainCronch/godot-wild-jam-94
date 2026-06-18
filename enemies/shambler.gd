extends CharacterBody2D
class_name Shambler

const PLAYER_FOLLOW_FACTOR := 1.0
const SEPARATION_FACTOR := 1.0
const SEPARATION_SPEED := 5000.0
const CLIMB_ACCELERATION := 15.0
const MAX_SEPARATION := 3
const CLIMB_SPEED := -4.0
const CLIMB_BOOST := 1000.0
const AI_UPDATE := 0.2

@export var plat_comp: PlatformerComponent
@export var enemy_check: Area2D
@export var wall_check: RayCast2D
@export var sprite: Polygon2D

var step_tween: Tween
var current_speed := SEPARATION_SPEED
var player_dir := Vector2()
var desired := Vector2()
var step_duration := 0.3
var pass_duration := 0.7
var stepping := false
var ai_timer := 0.0


func _ready() -> void:
	current_speed = SEPARATION_SPEED
	stepping = false
	await get_tree().current_scene.step_tick.timeout
	if is_instance_valid(step_tween): step_tween.kill()
	step_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	step_tween.tween_callback(func():
		current_speed = plat_comp.base_speed
		stepping = true
	)
	step_tween.tween_interval(step_duration)
	step_tween.tween_callback(func():
		current_speed = SEPARATION_SPEED
		stepping = false
	)
	step_tween.tween_interval(pass_duration)


func _process(delta: float) -> void:
	ai_timer += delta


func _physics_process(delta: float) -> void:
	player_dir = global_position.direction_to(Global.player.global_position)
	desired = player_dir * PLAYER_FOLLOW_FACTOR * (1.0 if stepping else 0.0)
	
	if ai_timer < AI_UPDATE: desired = (desired + separate()).normalized()
	plat_comp.dir = desired
	
	wall_check.set_collision_mask_value(1, plat_comp.position_z > Global.TILE_HEIGHT)
	wall_check.set_collision_mask_value(2, plat_comp.position_z > Global.TILE_HEIGHT * 2)
	wall_check.set_collision_mask_value(3, plat_comp.position_z > Global.TILE_HEIGHT * 3)
	
	wall_check.rotation = player_dir.angle()
	
	if wall_check.is_colliding():# and Global.player.plat_comp.floor_height > plat_comp.floor_height:
		plat_comp.velocity_z = CLIMB_SPEED
		velocity += player_dir * CLIMB_BOOST * delta
		plat_comp.air_acceleration = CLIMB_ACCELERATION
		plat_comp.speed = 0.0
	else:
		plat_comp.air_acceleration = plat_comp.base_air_acceleration
		plat_comp.speed = current_speed


func separate() -> Vector2:
	ai_timer = 0.0
	var output := Vector2()
	var i := 0
	for enemy in enemy_check.get_overlapping_areas():
		if enemy is HitboxComponent:
			if global_position.distance_squared_to(enemy.global_position) == 0.0: continue
			if i > MAX_SEPARATION: break
			output += enemy.global_position.direction_to(global_position) / global_position.distance_to(enemy.global_position) * SEPARATION_FACTOR
	return output


func _on_damage_taken(_attack: Attack) -> void:
	Global.player.camera_holder.shake(0.02)
	(sprite.material as ShaderMaterial).set_shader_parameter("active", true)
	await get_tree().create_timer(0.1).timeout
	(sprite.material as ShaderMaterial).set_shader_parameter("active", false)
