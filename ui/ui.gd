extends CanvasLayer


@export var health_label: Label
@export var ammo_label: Label
@export var progress_bar: TextureProgressBar


func _process(_delta: float) -> void:
	health_label.text = str(Global.player.health_comp.health)
	ammo_label.text = str(Global.player.weapon.state_machine.current_state.ui_info)
	progress_bar.value = Global.player.weapon.state_machine.current_state.ui_info
