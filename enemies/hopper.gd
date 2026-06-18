extends CharacterBody2D
class_name Hopper

const PLAYER_FOLLOW_FACTOR := 1.0
const SEPARATION_FACTOR := 5.0
const MAX_SEPARATION := 3
const AI_UPDATE := 0.2
const HOP_SPEED := 50.0
const HOP_BOOST := 250.0

@export var plat_comp: PlatformerComponent
@export var enemy_check: Area2D
@export var sprite: Polygon2D

var hop_tween: Tween
var player_dir := Vector2()
var desired := Vector2()
var wait_duration := 1.0
var hopping := false
var ai_timer := 0.0


func _ready() -> void:
	#current_speed = SEPARATION_SPEED
	#stepping = false
	await get_tree().current_scene.step_tick.timeout
	if is_instance_valid(hop_tween): hop_tween.kill()
	hop_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	hop_tween.tween_callback(func():
		#current_speed = plat_comp.base_speed
		#hopping = true
		if not plat_comp.airborne:
			player_dir = global_position.direction_to(Global.player.global_position)
			desired = player_dir * PLAYER_FOLLOW_FACTOR
			desired = (desired + separate()).normalized()
			
			plat_comp.velocity_z += plat_comp.base_jump_force
			plat_comp.target.velocity = desired * HOP_BOOST
			#plat_comp.speed = HOP_SPEED
	)
	hop_tween.tween_interval(wait_duration + randfn(0.0, 0.1))


func _process(delta: float) -> void:
	ai_timer += delta


func _physics_process(delta: float) -> void:
	
	
	#plat_comp.dir = desired
	
	if plat_comp.airborne:
		plat_comp.target.velocity += desired * HOP_SPEED * delta
		#plat_comp.speed = 0.0
	
	#wall_check.set_collision_mask_value(1, plat_comp.position_z > Global.TILE_HEIGHT)
	#wall_check.set_collision_mask_value(2, plat_comp.position_z > Global.TILE_HEIGHT * 2)
	#wall_check.set_collision_mask_value(3, plat_comp.position_z > Global.TILE_HEIGHT * 3)
	#
	#wall_check.rotation = player_dir.angle()
	#
	#if wall_check.is_colliding():# and Global.player.plat_comp.floor_height > plat_comp.floor_height:
		#pass
	#else:
		#pass


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
