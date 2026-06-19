extends CanvasLayer
class_name UI

@export var world: World
@export var health_bar: TextureProgressBar
@export var ammo_label: Label
@export var progress_bar: TextureProgressBar


func _ready() -> void:
	await get_tree().process_frame
	Global.player.health_comp.health_changed.connect(health_changed)


func _process(_delta: float) -> void:
	ammo_label.text = str(Global.player.weapon.state_machine.current_state.ui_info)
	progress_bar.value = Global.player.weapon.state_machine.current_state.ui_info


func health_changed(health: int) -> void:
	health_bar.value += health
