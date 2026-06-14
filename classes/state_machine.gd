extends Node
class_name StateMachine

@export var initial_state : State
@export var debug_text : Label

var parent : Node
var current_state : State
var states : Dictionary = {}


func _ready() -> void :
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(_on_child_transition)

	var above = get_parent()
	await above.ready
	parent = above

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _process(_delta) -> void :
	if current_state:
		if debug_text: debug_text.text = current_state.name
		current_state.update(_delta)


func _physics_process(_delta) -> void:
	if current_state:
		current_state.physics_update(_delta)


func _on_child_transition(state, new_state_name) -> void :
	if state != current_state:
		printerr("State ", state, " not current state!")
		return

	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		printerr("State ", new_state, " not found!")
		return

	if current_state:
		current_state.exit()

	current_state = new_state

	new_state.enter()
