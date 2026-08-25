class_name CampaignCity extends Area2D

@export var city_name: String

@onready var name_label: Label = $Name

var attackable := false

signal clicked(city: CampaignCity)

func _ready() -> void:
	name_label.text = city_name

func apply_owner(faction: CampaignState.Faction) -> void:
	modulate = CampaignState.faction_color(faction)

func set_attackable(value: bool) -> void:
	attackable = value
	input_pickable = value

func _on_mouse_entered() -> void:
	scale = Vector2(1.35, 1.35)
	z_index = 2

func _on_mouse_exited() -> void:
	scale = Vector2.ONE
	z_index = 0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if !attackable || !(event is InputEventMouseButton):
		return
	if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
		clicked.emit(self)
