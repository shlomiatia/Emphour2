class_name BattleHud extends Control

const ENEMY_COLOR := Color(0.9, 0.26, 0.22)
const PLAYER_COLOR := Color(0.24, 0.58, 0.95)
const NORMAL_COLOR := Color("#180f24")

@export var loss_icon_scene: PackedScene
@onready var meter: Panel = $Meter
@onready var preview: ColorRect = $Meter/Preview
@onready var blue_half: ColorRect = $Meter/BlueHalf
@onready var red_half: ColorRect = $Meter/RedHalf
@onready var enemy_losses: HBoxContainer = $EnemyLosses
@onready var player_losses: HBoxContainer = $PlayerLosses

var balance_tween: Tween
var preview_tween: Tween
var balance := 0
var player_loss_count := 0
var enemy_loss_count := 0
var losses_faded := false

func set_losses(player: int, enemy: int) -> void:
    player_loss_count = player
    enemy_loss_count = enemy
    losses_faded = false
    set_loss_icons(player_losses, player, PLAYER_COLOR)
    set_loss_icons(enemy_losses, enemy, ENEMY_COLOR)

func wait_for_preview() -> void:
    if preview_tween && preview_tween.is_valid() && preview_tween.is_running():
        await preview_tween.finished

func fade_losses() -> Signal:
    losses_faded = true
    var tween := CardMotion.create(self, Tween.EASE_IN)
    for icon in get_loss_icons():
        tween.parallel().tween_property(icon, "modulate:a", 0.0, 0.2)
    tween.tween_callback(clear_losses)
    return tween.finished

func remove_loss(side: int) -> void:
    var container := player_losses if side == GameRules.Side.PLAYER else enemy_losses
    var icons := container.get_children().filter(func(icon: Node) -> bool: return !icon.is_queued_for_deletion())
    if !icons.is_empty():
        icons[-1].queue_free()

func set_preview(value: int) -> void:
    if !losses_faded:
        set_loss_icons(player_losses, player_loss_count, PLAYER_COLOR)
        set_loss_icons(enemy_losses, enemy_loss_count, ENEMY_COLOR)
    var current := meter_position(balance)
    var target := meter_position(value)
    if preview_tween:
        preview_tween.kill()
    preview_tween = CardMotion.create(self)
    preview.visible = !is_equal_approx(current, target)
    preview.color = half_color(blue_half.color if target > current else red_half.color)
    blue_half.z_index = 3 if target > current else 1
    red_half.z_index = 3 if target < current else 1
    preview_tween.parallel().tween_property(preview, "position:x", minf(current, target), 0.4)
    preview_tween.parallel().tween_property(preview, "size:x", absf(target - current), 0.4)

func set_balance(value: int, animate := true) -> void:
    var current := meter_position(balance)
    var target := meter_position(value)
    balance = value
    if preview_tween:
        preview_tween.kill()
    if balance_tween:
        balance_tween.kill()
    if !animate:
        preview.visible = false
        set_meter_boundary(target)
        return
    preview.position.x = minf(current, target)
    preview.size.x = absf(target - current)
    balance_tween = CardMotion.create(self)
    balance_tween.parallel().tween_property(blue_half, "size:x", target - 3.0, 0.4)
    balance_tween.parallel().tween_property(red_half, "position:x", target, 0.4)
    balance_tween.parallel().tween_property(red_half, "size:x", meter.size.x - target - 3.0, 0.4)
    balance_tween.tween_callback(hide_preview)

func hide_preview() -> void:
    preview.visible = false
    preview.position.x = meter_position(balance)
    preview.size.x = 0.0

func half_color(color: Color) -> Color:
    return Color(color.r / 2.0, color.g / 2.0, color.b / 2.0, 1.0)

func set_meter_boundary(value: float) -> void:
    blue_half.size.x = value - 3.0
    red_half.position.x = value
    red_half.size.x = meter.size.x - value - 3.0

func meter_position(value: int) -> float:
    var limit := GameRules.WINNING_SCORE
    var ratio := clampf((value + limit) / float(limit * 2), 0.0, 1.0)
    return 3.0 + ratio * (meter.size.x - 6.0)

func set_loss_icons(container: HBoxContainer, losses: int, color: Color) -> void:
    while container.get_child_count() < losses:
        add_loss_icon(container, color)
    while container.get_child_count() > losses:
        var icon := container.get_child(container.get_child_count() - 1)
        container.remove_child(icon)
        icon.queue_free()

func add_loss_icon(container: HBoxContainer, color: Color) -> void:
    var icon := loss_icon_scene.instantiate() as TextureRect
    icon.modulate = color
    icon.modulate.a = 0.0
    container.add_child(icon)
    CardMotion.create(self, Tween.EASE_OUT).tween_property(icon, "modulate:a", 1.0, 0.2)

func clear_losses() -> void:
    for icon in get_loss_icons():
        icon.get_parent().remove_child(icon)
        icon.queue_free()

func get_loss_icons() -> Array[Node]:
    return enemy_losses.get_children() + player_losses.get_children()
