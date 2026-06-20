extends Node2D
class_name Weapon

@export var state_machine: StateMachine
@export var states: Array[State] = []

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
