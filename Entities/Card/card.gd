class_name Card extends Node2D

const HAND_SCALE := Vector2(0.36, 0.36)
const BOARD_SCALE := Vector2(0.3, 0.3)
const DISCARD_SCALE := Vector2(0.22, 0.22)

@export var card_name := "Militia"
@export var side: int = GameRules.Side.PLAYER
@export var face_down := false
@onready var front: Node2D = $Front
@onready var back: Node2D = $Back
@onready var art: Sprite2D = $Front/Art
@onready var title: Label = $Front/Title
@onready var stats: Label = $Front/Stats
@onready var selection: NinePatchRect = $Selection

var data: CardData
var draggable := false
var dragging := false
var selectable := false
var drag_offset := Vector2.ZERO

signal dropped(card: Card, point: Vector2)
signal selected(card: Card)

func _ready() -> void:
    data = CardCatalog.get_data(card_name)
    refresh()
    set_process_input(false)

func refresh() -> void:
    art.texture = load("res://Textures/Cards/" + card_name + ".png")
    title.text = card_name
    stats.text = "Strength %d   Attack %d   Defence %d" % [data.strength, data.attack, data.defence]
    set_hidden(face_down)

func set_hidden(value: bool) -> void:
    face_down = value
    front.visible = !face_down
    back.visible = face_down

func set_selectable(value: bool) -> void:
    selectable = value
    selection.visible = value

func stop_dragging() -> void:
    dragging = false
    set_process_input(false)

func attack_card(defender: Card) -> void:
    var start := global_position
    var tween := create_tween()
    tween.tween_property(self, "global_position", defender.global_position, 0.18)
    tween.tween_property(self, "global_position", start, 0.18)
    await tween.finished

func defend() -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(0.4, 1.0, 0.5), 0.15)
    tween.tween_property(self, "modulate", Color.WHITE, 0.15)
    await tween.finished

func _on_input_event(_viewport: Node, event: InputEvent, _shape: int) -> void:
    if !(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && event.pressed):
        return
    if selectable:
        selected.emit(self)
    elif draggable:
        dragging = true
        drag_offset = global_position - get_global_mouse_position()
        set_process_input(true)
        z_index = 20
    get_viewport().set_input_as_handled()

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        global_position = get_global_mouse_position() + drag_offset
    elif event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT && !event.pressed:
        stop_dragging()
        dropped.emit(self, get_global_mouse_position())
        get_viewport().set_input_as_handled()
