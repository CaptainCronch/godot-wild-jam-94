extends CanvasLayer


@export var health_label: Label


func _process(_delta: float) -> void:
	health_label.text = str(Global.player.health_comp.health)
