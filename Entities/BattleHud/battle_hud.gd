class_name BattleHud extends Control

@onready var enemy_stats: Label = $EnemyStats
@onready var player_stats: Label = $PlayerStats
@onready var meter: Panel = $Meter
@onready var preview: Panel = $Meter/Preview
@onready var marker: Panel = $Meter/Marker

var marker_tween: Tween

func set_losses(player: int, enemy: int) -> void:
    enemy_stats.text = "ENEMY   Losses %d" % enemy
    player_stats.text = "PLAYER   Losses %d" % player

func set_preview(value: int) -> void:
    preview.position.x = meter_position(value, preview)

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
