class_name Card extends Node2D

const SIZE := Vector2(182, 253)
const HIGHLIGHT_COLOR := Color("#fee761")
const ATTACK_ICONS := {
    CardData.AttackType.MISSILE: preload("res://Textures/Missle.png"),
    CardData.AttackType.CAVALRY: preload("res://Textures/Cavalry.png"),
    CardData.AttackType.ARMOR_PIERCING: preload("res://Textures/Armor.png")
}
const GROUP_ICONS := {"Peasants": preload("res://Textures/Peasants.png"), "Nobility": preload("res://Textures/Nobility.png")}
const FACTION_PALETTES := {
    CampaignState.Faction.FRANKS: [Color("#173967"), Color("#0b1c36"), Color("#5d85be")],
    CampaignState.Faction.ENGLISH: [Color("#a22633"), Color("#520d15"), Color("#d86a76")],
    CampaignState.Faction.HRE: [Color("#bd6d18"), Color("#603405"), Color("#e4a25a")]
}
@export var card_name := "Militia"
@export var side: int = GameRules.Side.PLAYER
@export var faction: CampaignState.Faction = CampaignState.Faction.FRANKS
@export var face_down := false
@onready var front: Node2D = $Front
@onready var back: Node2D = $Back
@onready var art: Sprite2D = $Front/Art
@onready var title: Label = $Front/Title
@onready var count: Label = $Front/Count
@onready var strength: Label = $Front/Strength
@onready var attack: Label = $Front/Attack
@onready var defence: Label = $Front/Defence
@onready var attack_icon: Sprite2D = $Front/AttackIcon
@onready var defence_icon: Sprite2D = $Front/DefenceIcon
@onready var attack_counter: Sprite2D = $Front/AttackCounter
@onready var counter: Sprite2D = $Front/Counter
@onready var group_icon: Sprite2D = $Front/GroupIcon

var data: CardData
var deck_entry: CampaignCard
var draggable := false
var dragging := false
var hovering := false
var hover_enabled := false
var disabled := false
var highlighted := false
var attacking := false
var moving := false

signal draw_finished

func _ready() -> void:
    add_to_group("cards")
    data = CardCatalog.get_data(card_name)
    refresh()

func _process(_delta: float) -> void:
    (art.material as ShaderMaterial).set_shader_parameter("modulate", modulate * front.modulate)

func refresh() -> void:
    art.texture = load("res://Textures/Cards/" + card_name + ".png")
    title.text = card_name
    strength.text = str(data.strength)
    attack.text = str(data.attack)
    defence.text = str(data.defence)
    group_icon.texture = GROUP_ICONS["Nobility" if RewardRules.belongs_to(card_name, "Nobility") else "Peasants"]
    set_icons()
    set_side(side)
    set_faction(faction)
    set_hidden(face_down)

func set_icons() -> void:
    attack_icon.texture = ATTACK_ICONS.get(data.attack_type)
    defence_icon.texture = preload("res://Textures/Armor.png") if data.armored else ATTACK_ICONS.get(data.anti_attack)
    attack_icon.visible = attack_icon.texture != null
    defence_icon.visible = defence_icon.texture != null
    attack_counter.visible = data.attack_type == CardData.AttackType.ARMOR_PIERCING
    counter.visible = data.anti_attack != CardData.AttackType.NONE && !data.armored

func set_side(value: int) -> void:
    side = value

func set_faction(value: CampaignState.Faction) -> void:
    faction = value
    var material := art.material as ShaderMaterial
    material.set_shader_parameter("is_colored", FACTION_PALETTES.has(faction))
    if !FACTION_PALETTES.has(faction):
        return
    var palette: Array = FACTION_PALETTES[faction]
    material.set_shader_parameter("replace_0", palette[0])
    material.set_shader_parameter("replace_1", palette[1])
    material.set_shader_parameter("replace_2", palette[2])

func set_hidden(value: bool) -> void:
    face_down = value
    front.visible = !face_down
    back.visible = face_down

func flip_face_up() -> Signal:
    return CardMotion.flip_face_up(self)

func set_preview_count(value: int) -> void:
    count.text = "x%d" % value
    count.show()

func set_disabled(value: bool) -> void:
    disabled = value
    refresh_color()

func set_highlighted(value: bool) -> void:
    highlighted = value
    refresh_color()

func refresh_color() -> void:
    var color := HIGHLIGHT_COLOR if highlighted else Color(0.45, 0.45, 0.45) if disabled else Color.WHITE
    front.modulate = color
    back.modulate = color

func set_hovering(value: bool) -> void:
    hovering = value

func contains_point(point: Vector2) -> bool:
    return Rect2(-SIZE / 2.0, SIZE).has_point(to_local(point))

func get_global_rect() -> Rect2:
    var points := [Vector2(-SIZE.x, -SIZE.y) / 2.0, Vector2(SIZE.x, -SIZE.y) / 2.0, SIZE / 2.0, Vector2(-SIZE.x, SIZE.y) / 2.0]
    var result := Rect2(global_transform * points[0], Vector2.ZERO)
    for point in points:
        result = result.expand(global_transform * point)
    return result

func fade_out() -> void:
    await CardMotion.fade_out(self)

func move_to(target: Vector2, fade := false, target_scale := Vector2.ONE) -> void:
    await CardMotion.move_to(self, target, fade, target_scale)

func move_to_line(target: Vector2) -> void:
    CardMotion.move_to_line(self, target)

func finish_move() -> void:
    moving = false

func retreat_out(side_to_retreat: int) -> void:
    CardMotion.retreat_out(self, side_to_retreat)

func attack_card(defender: Card) -> Signal:
    return CardMotion.attack(self, defender)

func finish_attack() -> void:
    attacking = false
    z_index = 2
