extends CharacterBody2D
class_name Shambler

var step_duration := 0.3
var pass_duration := 0.7

@export var plat_comp: PlatformerComponent

var step_tween: Tween


func _ready() -> void:
	if is_instance_valid(step_tween): step_tween.kill()
	step_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_loops(0)
	step_tween.tween_callback(func (): plat_comp.speed = plat_comp.base_speed)
	step_tween.tween_interval(step_duration)
	step_tween.tween_callback(func (): plat_comp.speed = 0.0)
	step_tween.tween_interval(pass_duration)
	#step_tween.tween_property(plat_comp, "speed", plat_comp.base_speed, STEP_DURATION)
	#step_tween.tween_property(plat_comp, "speed", 0.0, PASS_DURATION)


func _process(_delta: float) -> void:
	plat_comp.dir = global_position.direction_to(Global.player.global_position)
