class_name BoardZoomer extends RefCounted

var board: Board

func _init(game_board: Board) -> void:
    board = game_board

func change_zoom(animated := true) -> void:
    var zoom := get_zoom()
    if !animated:
        board.position.y = zoom["target_y"]
        board.scale = Vector2.ONE * zoom["target_scale"]
        return
    var tween := board.create_tween().set_parallel()
    tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
    tween.tween_property(board, "position:y", zoom["target_y"], 0.3)
    tween.tween_property(board, "scale", Vector2.ONE * zoom["target_scale"], 0.3)

func get_zoom() -> Dictionary:
    var rows := [board.player_row, board.enemy_row]
    var zoom := get_front_zoom(rows.min(), rows.max())
    zoom["target_scale"] = minf(zoom["target_scale"], get_max_scale())
    if get_max_scale() <= 0.7:
        zoom["target_y"] = 450.0
    return zoom

func get_front_zoom(min_row: int, max_row: int) -> Dictionary:
    if min_row == 1 && max_row == 2:
        return {"target_scale": 1.0, "target_y": 540.0}
    if min_row <= 0 && max_row >= 3:
        return {"target_scale": 0.7, "target_y": 450.0}
    if max_row >= 3:
        return {"target_scale": 0.9, "target_y": 320.0}
    return {"target_scale": 0.9, "target_y": 575.0}

func get_max_scale() -> float:
    if board.slot_count >= 16:
        return 0.55
    if board.slot_count >= 14:
        return 0.6
    if board.slot_count >= 12:
        return 0.7
    if board.slot_count >= 11:
        return 0.8
    return 0.9 if board.slot_count >= 10 else 1.0
