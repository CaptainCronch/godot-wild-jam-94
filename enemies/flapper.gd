extends Enemy
class_name Flapper

const FLAP_HEIGHT := -48.0
const HEIGHT_RANGE := 20.0


func _physics_process(delta: float) -> void:
	super(delta)
	
	if plat_comp.position_z > plat_comp.floor_height + FLAP_HEIGHT + randf_range(-HEIGHT_RANGE, HEIGHT_RANGE):
		plat_comp.velocity_z = plat_comp.jump_force
		play_animation("flap")
