class_name CampaignCity extends Area2D

@export var city_id: String
@export var display_name: String
@export var faction: CampaignState.Faction = CampaignState.Faction.FRANKS
@export var route_index := 0

@onready var name_label: Label = $Name
@onready var marker: Sprite2D = $Marker
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var attackable := false

signal clicked(city: CampaignCity)
signal hovered(city: CampaignCity)
signal unhovered(city: CampaignCity)

func apply_owner(faction: CampaignState.Faction) -> void:
    marker.modulate = CampaignState.faction_color(faction)

func set_attackable(value: bool) -> void:
    attackable = value
    input_pickable = value
    if attackable:
        animation_player.play("Pulse")
    else:
        animation_player.play("RESET")

func _ready() -> void:
    set_attackable(false)
    apply_owner(faction)
    name_label.text = tr(display_name)

func _on_mouse_entered() -> void:
    if attackable:
        animation_player.play("Large")
        hovered.emit(self)
    z_index = 2

func _on_mouse_exited() -> void:
    if attackable:
        animation_player.play("Pulse")
        unhovered.emit(self)
    z_index = 0

func _on_input_event(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
    if !attackable || !(event is InputEventMouseButton):
        return
    if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
        clicked.emit(self)
