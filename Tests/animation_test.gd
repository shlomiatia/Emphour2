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
    verify_even_slots(board)
    var player := create_card(GameRules.Side.PLAYER)
    var enemy := create_card(GameRules.Side.ENEMY)
    root.add_child(player)
    root.add_child(enemy)
    assert(board.get_node("Rows").get_child_count() == 2)
    board.get_row_slots(Board.PLAYER_ROW)[2].place(player)
    board.get_row_slots(Board.ENEMY_ROW)[2].place(enemy)
    var attack := player.attack_card(enemy)
    assert(player.z_index == 100)
    await attack
    assert(player.z_index == 2)
    await verify_card_scale(board)
    var defeated := create_card(GameRules.Side.PLAYER)
    root.add_child(defeated)
    await process_frame
    await defeated.fade_out()
    assert(defeated.modulate.a < 0.01)
    quit()

func verify_even_slots(board: Board) -> void:
    board.slot_count = 4
    var slots := board.get_row_slots(Board.PLAYER_ROW)
    assert(slots.size() == 4)
    assert(is_zero_approx(slots.reduce(func(sum: float, slot: CardSlot) -> float: return sum + slot.position.x, 0.0)))
    board.slot_count = 3

func verify_card_scale(board: Board) -> void:
    var card := create_card(GameRules.Side.PLAYER)
    root.add_child(card)
    board.get_row_slots(Board.PLAYER_ROW)[0].place(card)
    assert(card.position.length() > 1.0)
    for _frame in 20:
        await process_frame
    assert(card.scale.is_equal_approx(Vector2.ONE))

func create_card(side: int) -> Card:
    var card := CARD_SCENE.instantiate() as Card
    card.side = side
    return card
