class_name BattleHud extends Control

@onready var enemy_stats: RichTextLabel = $EnemyStats
@onready var player_stats: RichTextLabel = $PlayerStats
@onready var balance_label: Label = $BalanceLabel
@onready var marker: Panel = $Meter/Marker

func set_strengths(player: int, enemy: int, player_losses: int, enemy_losses: int) -> void:
    enemy_stats.text = "[center]ENEMY\nStrength %d   Losses %d[/center]" % [enemy, enemy_losses]
    player_stats.text = "[center]PLAYER\nStrength %d   Losses %d[/center]" % [player, player_losses]

func set_balance(value: int) -> void:
    var display := "+%d" % value if value > 0 else str(value)
    balance_label.text = "BALANCE OF POWER  %s" % display
    var ratio := clampf((value + GameRules.WINNING_SCORE) / float(GameRules.WINNING_SCORE * 2), 0.0, 1.0)
    marker.position.x = ratio * $Meter.size.x - marker.size.x / 2.0
