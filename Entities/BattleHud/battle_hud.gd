class_name BattleHud extends Control

@onready var meter: Panel = $Meter
@onready var preview: Panel = $Meter/Preview
@onready var marker: Panel = $Meter/Marker
@onready var enemy_losses := [$EnemyLoss1, $EnemyLoss2, $EnemyLoss3]
@onready var player_losses := [$PlayerLoss1, $PlayerLoss2, $PlayerLoss3]

var marker_tween: Tween
var preview_tween: Tween

func set_losses(player: int, enemy: int) -> void:
    set_loss_icons(player_losses, player)
    set_loss_icons(enemy_losses, enemy)

func fade_losses() -> Signal:
    var tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
    for icon in enemy_losses + player_losses:
        if icon.visible:
            tween.parallel().tween_property(icon, "modulate:a", 0.0, 0.2)
    tween.tween_callback(clear_losses)
    return tween.finished

func remove_loss(side: int) -> void:
    var icons := player_losses if side == GameRules.Side.PLAYER else enemy_losses
    for index in range(icons.size() - 1, -1, -1):
        if icons[index].visible:
            icons[index].hide()
            return

func set_preview(value: int) -> void:
    var target := meter_position(value, preview)
    if preview_tween:
        preview_tween.kill()
    preview_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    preview_tween.tween_property(preview, "position:x", target, 0.4)

func set_balance(value: int, animate := true) -> void:
    var target := meter_position(value, marker)
    set_preview(value)
    if marker_tween:
        marker_tween.kill()
    if !animate:
        marker.position.x = target
        return
    marker_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    marker_tween.tween_property(marker, "position:x", target, 0.4)

func meter_position(value: int, item: Control) -> float:
    var limit := GameRules.WINNING_SCORE
    var ratio := clampf((value + limit) / float(limit * 2), 0.0, 1.0)
    return ratio * meter.size.x - item.size.x / 2.0

func set_loss_icons(icons: Array, losses: int) -> void:
    for index in icons.size():
        var visible := index < losses
        if visible && !icons[index].visible:
            icons[index].modulate.a = 0.0
            icons[index].show()
            create_tween().tween_property(icons[index], "modulate:a", 1.0, 0.2)
        elif !visible:
            icons[index].hide()

func clear_losses() -> void:
    for icon in enemy_losses + player_losses:
        icon.hide()
        icon.modulate.a = 1.0
