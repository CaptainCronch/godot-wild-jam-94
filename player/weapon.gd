extends Node2D
class_name Weapon

@export var state_machine: StateMachine
@export var states: Array[State] = []
@export var weapon_animator: AnimationPlayer

@onready var states_left := states.duplicate()


func _ready() -> void:
	states_left.erase(state_machine.initial_state)


func fire() -> void: state_machine.current_state.fire()


func fire_hold() -> void: state_machine.current_state.fire_hold()


func fire_release() -> void: state_machine.current_state.fire_release()


func switch() -> void:
	var new_state := randi_range(0, states_left.size() - 1)
	state_machine.current_state.transitioned.emit(state_machine.current_state, states_left[new_state].name)
	states_left.remove_at(new_state)
	if states_left.is_empty():
		states_left = states.duplicate()


func upgrade(which: String) -> void:
	match which:
		"revolver_uzi": states[0].uzi_upgrade = true
		"revolver_pierce": states[0].pierce_upgrade = true
		"explosion_damage": states[1].damage_upgrade = true
		"explosion_self_damage": states[1].self_damage_upgrade = true
		"disc_girth": states[2].girth_upgrade = true
		"disc_double": states[2].double_upgrade = true
		"whip_double": states[3].double_upgrade = true
		"whip_girth":
			states[3].sourspot.collider.shape.size.y *= 2
			states[3].sweetspot.collider.shape.size.y *= 2
			states[3].sourspot.attack.size *= 2
			states[3].sweetspot.attack.size *= 2
