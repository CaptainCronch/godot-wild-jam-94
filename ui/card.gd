extends Control
class_name Card

signal card_selected(card: Card)

@onready var card_texture: TextureRect = %CardTexture
@onready var title_label: Label = %TitleLabel
@onready var description_label: Label = %DescriptionLabel
@onready var tooltip_label: Label = %TooltipLabel

var can_select := false

@export var mutation: Mutation

func _ready() -> void:
	title_label.text = mutation.name
	description_label.text = mutation.description
	tooltip_label.text = mutation.tooltip


func _on_gui_input(event: InputEvent) -> void:
	if not can_select: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		card_selected.emit(self)


func _on_timer_timeout() -> void:
	can_select = true
