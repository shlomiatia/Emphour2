class_name Card extends Node2D

const ATTACK_ICONS := {
    CardData.AttackType.MISSILE: preload("res://Textures/Missle.png"),
    CardData.AttackType.CAVALRY: preload("res://Textures/Cavalry.png")
}
const DEFENCE_ICONS := {
    CardData.DefenceType.ARMOR: preload("res://Textures/Armor.png"),
    CardData.DefenceType.RETREAT: preload("res://Textures/Retreat.png")
}

@export var card_name := "Militia"
@export var side: int = GameRules.Side.PLAYER
@export var face_down := false
@onready var front: Node2D = $Front
@onready var back: Node2D = $Back
@onready var art: Sprite2D = $Front/Art
@onready var title: Label = $Front/Title
@onready var strength: Label = $Front/Strength
@onready var attack: Label = $Front/Attack
@onready var defence: Label = $Front/Defence
@onready var attack_icon: Sprite2D = $Front/AttackIcon
@onready var defence_icon: Sprite2D = $Front/DefenceIcon
@onready var counter: Sprite2D = $Front/Counter

var data: CardData
var draggable := false
var dragging := false
var selectable := false
var hovering := false
var hover_enabled := false
var disabled := false
var highlighted := false
var attacking := false

func _ready() -> void:
    data = CardCatalog.get_data(card_name)
    refresh()

func refresh() -> void:
    art.texture = load("res://Textures/Cards/" + card_name + ".png")
    title.text = card_name
    strength.text = str(data.strength)
    attack.text = str(data.attack)
    defence.text = str(data.defence)
    set_icons()
    set_hidden(face_down)

func set_icons() -> void:
    attack_icon.texture = ATTACK_ICONS.get(data.attack_type)
    defence_icon.texture = ATTACK_ICONS.get(data.anti_attack, DEFENCE_ICONS.get(data.defence_type))
    attack_icon.visible = attack_icon.texture != null
    defence_icon.visible = defence_icon.texture != null
    counter.visible = data.anti_attack != CardData.AttackType.NONE

func set_hidden(value: bool) -> void:
    face_down = value
    front.visible = !face_down
    back.visible = face_down

func set_selectable(value: bool) -> void:
    selectable = value

func set_disabled(value: bool) -> void:
    disabled = value
    refresh_color()

func set_highlighted(value: bool) -> void:
    highlighted = value
    refresh_color()

func refresh_color() -> void:
    var color := Color("#fee761") if highlighted else Color(0.45, 0.45, 0.45) if disabled else Color.WHITE
    front.modulate = color
    back.modulate = color

func set_hovering(value: bool) -> void:
    hovering = value

func contains_point(point: Vector2) -> bool:
    return Rect2(-91, -126.5, 182, 253).has_point(to_local(point))

func get_global_rect() -> Rect2:
    var points := [Vector2(-91, -126.5), Vector2(91, -126.5), Vector2(91, 126.5), Vector2(-91, 126.5)]
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
    var target_y := 1280.0 if side_to_retreat == GameRules.Side.PLAYER else -200.0
    var tween := create_tween()
    tween.set_ease(Tween.EASE_OUT)
    tween.set_trans(Tween.TRANS_SINE)
    tween.tween_property(self, "global_position:y", target_y, 0.3)

func attack_card(defender: Card) -> Signal:
    attacking = true
    z_index = 100
    var start := global_position
    var tween := create_tween()
    tween.tween_property(self, "global_position", defender.global_position, 0.18)
    tween.tween_property(self, "global_position", start, 0.18)
    tween.tween_callback(finish_attack)
    return tween.finished

func finish_attack() -> void:
    attacking = false
    z_index = 2

func defend() -> void:
    var tween := create_tween()
    tween.tween_property(self, "modulate", Color(0.4, 1.0, 0.5), 0.15)
    tween.tween_property(self, "modulate", Color.WHITE, 0.15)
    await tween.finished
