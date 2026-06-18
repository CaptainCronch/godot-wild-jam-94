extends Node2D
class_name Weapon

@export var state_machine: StateMachine


func fire() -> void: state_machine.current_state.fire()

func fire_hold() -> void: state_machine.current_state.fire_hold()

func fire_release() -> void: state_machine.current_state.fire_release()
