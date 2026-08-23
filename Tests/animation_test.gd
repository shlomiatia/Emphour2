extends SceneTree

const CARD_SCENE := preload("res://Entities/Card/Card.tscn")

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    var board := load("res://Entities/Board/Board.tscn").instantiate() as Board
    board.position = Vector2(960, 540)
    root.add_child(board)
    await process_frame
    var player := create_card(GameRules.Side.PLAYER)
    var enemy := create_card(GameRules.Side.ENEMY)
    root.add_child(player)
    root.add_child(enemy)
    board.get_row_slots(2)[2].place(player)
    board.get_row_slots(1)[2].place(enemy)
    var result := board.advance(GameRules.Side.PLAYER)
    assert(!result["finished"])
    assert(board.get_row_slots(1)[2].get_card() == player)
    assert(board.get_row_slots(0)[2].get_card() == enemy)
    assert(player.position.length() > 1.0)
    for _frame in 20:
        await process_frame
    assert(board.scale.is_equal_approx(Vector2(0.9, 0.9)))
    assert(is_equal_approx(board.position.y, 575.0))
    await verify_card_scale(board)
    result = board.advance(GameRules.Side.PLAYER)
    assert(result["finished"])
    assert(enemy.get_parent() == board)
    for _frame in 20:
        await process_frame
    assert(enemy.global_position.y < 0.0)
    var defeated := create_card(GameRules.Side.PLAYER)
    root.add_child(defeated)
    await process_frame
    await defeated.fade_out()
    assert(defeated.modulate.a < 0.01)
    await verify_enemy_zoom()
    quit()

func verify_card_scale(board: Board) -> void:
    var card := create_card(GameRules.Side.PLAYER)
    root.add_child(card)
    board.get_row_slots(board.player_row)[0].place(card)
    assert(card.scale.x > 1.0)
    for _frame in 20:
        await process_frame
    assert(card.scale.is_equal_approx(Vector2.ONE))

func verify_enemy_zoom() -> void:
    var board := load("res://Entities/Board/Board.tscn").instantiate() as Board
    board.position = Vector2(960, 540)
    root.add_child(board)
    await process_frame
    board.advance(GameRules.Side.ENEMY)
    for _frame in 20:
        await process_frame
    assert(board.scale.is_equal_approx(Vector2(0.9, 0.9)))
    assert(is_equal_approx(board.position.y, 320.0))
    board.queue_free()

func create_card(side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.side = side
    return card
