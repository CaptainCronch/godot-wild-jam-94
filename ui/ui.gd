extends CanvasLayer
class_name UI

signal start

const EYE_TEXTURE_SIZE := 23.0
const HEALTH_BAR_TIME := 0.1

@export var world: World
@export var health_bar: TextureProgressBar
@export var health_animation_player: AnimationPlayer
@export var eye: TextureRect
@export var eye_animation_player: AnimationPlayer
@export var total_score: Label
@export var mutation_control: MutationControl
@export var revolver_chamber: TextureRect
@export var revolver_chamber_background: TextureRect
@export var fuse_bar: TextureProgressBar
@export var disc_bar: TextureProgressBar
@export var round_label: Label
@export var demon_label: Label
@export var heart_label: Label
@export var tutorial_delay: Timer
@export var end_screen: Control
@export var max_round_label: Label
@export var max_demon_label: Label
@export var max_heart_label: Label
@export var tutorial: AudioStreamPlayer

var health_tween: Tween

@onready var tutorial_screen: ColorRect = %TutorialScreen


func _ready() -> void:
	if OS.get_name() == "Web": $EndScreen/ResultsContainer/MarginContainer/HBoxContainer/QuitButton.hide()
	tutorial_screen.show()
	Global.ui = self
	await get_tree().process_frame
	#start.emit()
	Global.player.health_comp.health_changed.connect(_on_health_changed)


#func _process(_delta: float) -> void:
	#if is_instance_valid(world.current_demon_heart):
		#heart_pointer.offset_transform_position = world.current_demon_heart.global_position - Global.player.camera.global_position #+ Global.player.camera_holder.global_position
		#heart_pointer.offset_transform_position = heart_pointer.offset_transform_position.clamp(get_viewport().get_visible_rect().position, get_viewport().get_visible_rect().position + get_viewport().get_visible_rect().size)
	#ammo_label.text = str(Global.player.weapon.state_machine.current_state.ui_info)
	#progress_bar.value = Global.player.weapon.state_machine.current_state.ui_info


func animate_eye(number: int) -> void:
	total_score.text = str(number)
	eye_animation_player.play("add_heart")
	await eye_animation_player.animation_finished
	(eye.texture as AtlasTexture).region.position.y = EYE_TEXTURE_SIZE * (number % 10)


func _on_health_changed(health: int) -> void:
	health_animation_player.play("health_changed")
	health_bar.offset_transform_scale.y *= -1.0
	if is_instance_valid(health_tween): health_tween.kill()
	health_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	health_tween.tween_property(health_bar, "value", health, HEALTH_BAR_TIME)


func show_mutation_screen() -> void:
	tutorial.play()
	mutation_control.select_new_mutation()


func show_end_screen() -> void:
	round_label.text = str(Global.rounds_survived)
	demon_label.text = str(Global.demons_killed)
	heart_label.text = str(Global.points_collected)
	max_round_label.text = str(Global.most_rounds_survived)
	max_demon_label.text = str(Global.most_demons_killed)
	max_heart_label.text = str(Global.most_points_collected)
	tutorial.play()
	end_screen.show()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("space") and tutorial_screen.visible and tutorial_delay.is_stopped():
		tutorial_screen.hide()
		tutorial.play()
		await tutorial.finished
		get_tree().paused = false
		start.emit()
	if event.is_action_pressed("esc"):
		tutorial.play()
		Global.rounds_survived = world.current_wave
		Global.most_demons_killed = max(Global.most_demons_killed, Global.demons_killed)
		Global.most_points_collected = max(Global.most_points_collected, Global.points_collected)
		Global.most_rounds_survived = max(Global.most_rounds_survived, Global.rounds_survived)
		end_screen.visible = !end_screen.visible
		get_tree().paused = !get_tree().paused


func _on_starter_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.STARTER
	tutorial.play()
	await tutorial.finished
	get_tree().reload_current_scene()


func _on_difficult_button_pressed() -> void:
	Global.difficulty = Global.DIFFICULTIES.DIFFICULT
	tutorial.play()
	await tutorial.finished
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	tutorial.play()
	await tutorial.finished
	get_tree().quit()
