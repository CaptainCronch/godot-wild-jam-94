extends Enemy
class_name Hopper

const HOP_SPEED := 25.0
const HOP_BOOST := 125.0

var hop_tween: Tween
var wait_duration := 1.0
var hopping := false


func _init() -> void:
	_separation_factor = 3.0


func _ready() -> void:
	super()
	await get_tree().current_scene.step_tick.timeout
	if is_instance_valid(hop_tween): hop_tween.kill()
	hop_tween = create_tween().set_loops(0)
	hop_tween.tween_callback(func():
		if not plat_comp.airborne:
			separate()
			plat_comp.velocity_z += plat_comp.base_jump_force
			plat_comp.target.velocity = desired * HOP_BOOST
	)
	hop_tween.tween_interval(wait_duration + randf_range(-0.1, 0.1))


func _process(delta: float) -> void:
	ai_timer += delta


func _physics_process(delta: float) -> void:
	if plat_comp.airborne:
		plat_comp.target.velocity += desired * HOP_SPEED * delta
