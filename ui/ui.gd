extends CanvasLayer
class_name UI

const EYE_TEXTURE_SIZE := 23.0
const HEALTH_BAR_TIME := 0.1

@export var world: World
@export var health_bar: TextureProgressBar
@export var health_animation_player: AnimationPlayer
@export var ammo_label: Label
@export var progress_bar: TextureProgressBar
@export var eye: TextureRect
@export var eye_animation_player: AnimationPlayer
@export var total_score: Label
@export var mutation_control : Mutation_Control
@onready var tutorial_screen: ColorRect = %TutorialScreen

var health_tween: Tween


func _ready() -> void:
	await get_tree().process_frame
	Global.player.health_comp.health_changed.connect(_on_health_changed)


#func _process(_delta: float) -> void:
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
	mutation_control.select_new_mutation()

func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion and tutorial_screen.visible:
		tutorial_screen.hide()
		get_tree().paused = false
