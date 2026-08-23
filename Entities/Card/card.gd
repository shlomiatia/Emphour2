class_name Card extends Node2D

const HAND_SCALE := Vector2(0.36, 0.36)
const BOARD_SCALE := Vector2(0.3, 0.3)
const DISCARD_SCALE := Vector2(0.22, 0.22)
const HOVER_SCALE := Vector2(0.46, 0.46)

@export var card_name := "Militia"
@export var side: int = GameRules.Side.PLAYER
@export var face_down := false
@onready var front: Node2D = $Front
@onready var back: Node2D = $Back
@onready var art: Sprite2D = $Front/Art
@onready var title: Label = $Front/Title
@onready var stats: Label = $Front/Stats

var data: CardData
var draggable := false
var dragging := false
var selectable := false
var hovering := false
var hover_enabled := false
var disabled := false

func _ready() -> void:
    data = CardCatalog.get_data(card_name)
    refresh()

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

func set_disabled(value: bool) -> void:
    disabled = value
    var color := Color(0.45, 0.45, 0.45) if disabled else Color.WHITE
    front.modulate = color
    back.modulate = color

func set_hovering(value: bool) -> void:
    hovering = value

func contains_point(point: Vector2) -> bool:
    return Rect2(-165, -230, 330, 460).has_point(to_local(point))

func get_global_rect() -> Rect2:
    var points := [Vector2(-165, -230), Vector2(165, -230), Vector2(165, 230), Vector2(-165, 230)]
    var result := Rect2(global_transform * points[0], Vector2.ZERO)
    for point in points:
        result = result.expand(global_transform * point)
    return result

func fade_out() -> void:
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.3)
    await tween.finished

func retreat_out(side_to_retreat: int) -> void:
    var target_y := 1195.0 if side_to_retreat == GameRules.Side.PLAYER else -115.0
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "global_position:y", target_y, 0.3)

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
