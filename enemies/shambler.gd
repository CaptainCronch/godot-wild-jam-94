extends Enemy
class_name Shambler

const CLIMB_ACCELERATION := 15.0
const CLIMB_SPEED := -2.0
const CLIMB_BOOST := 500.0

@export var wall_check: RayCast2D

var step_tween: Tween
var step_duration := 0.3
var pass_duration := 0.7


func _ready() -> void:
	super()
	current_speed = 0.0
	await get_tree().current_scene.step_tick.timeout
	if is_instance_valid(step_tween): step_tween.kill()
	step_tween = create_tween().set_loops(0)
	step_tween.tween_callback(func():
		current_speed = plat_comp.base_speed
		disable_player_dir = false
		if not wall_check.is_colliding(): play_animation("step", false)
	)
	step_tween.tween_interval(step_duration)
	step_tween.tween_callback(func():
		current_speed = SEPARATION_SPEED
		disable_player_dir = true
	)
	step_tween.tween_interval(pass_duration)


func _process(delta: float) -> void:
	ai_timer += delta
	sprite.flip_h = velocity.x > 0.0
	if animation_player.current_animation == "climb":
		sprite.position.x = 0.0
	else:
		sprite.position.x = flip_offset if sprite.flip_h else -flip_offset


func _physics_process(delta: float) -> void:
	super(delta)
	
	wall_check.set_collision_mask_value(1, plat_comp.position_z > Global.TILE_HEIGHT)
	wall_check.set_collision_mask_value(2, plat_comp.position_z > Global.TILE_HEIGHT * 2)
	wall_check.set_collision_mask_value(3, plat_comp.position_z > Global.TILE_HEIGHT * 3)
	
	wall_check.rotation = player_dir.angle()
	
	if wall_check.is_colliding():
		plat_comp.velocity_z = CLIMB_SPEED
		velocity += player_dir * CLIMB_BOOST * delta
		plat_comp.air_acceleration = CLIMB_ACCELERATION
		plat_comp.speed = 0.0
		play_animation("climb", false)
	else:
		plat_comp.air_acceleration = plat_comp.base_air_acceleration
		plat_comp.speed = current_speed


func _on_damage_taken(attack: Attack) -> void:
	play_animation("hurt")
	super(attack)
