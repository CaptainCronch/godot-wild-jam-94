extends Enemy
class_name Flapper

const FLAP_HEIGHT := -96.0


func _physics_process(delta: float) -> void:
	super(delta)
	
	if plat_comp.position_z > plat_comp.floor_height + FLAP_HEIGHT + randf_range(-20, 20):
		plat_comp.velocity_z = plat_comp.jump_force
