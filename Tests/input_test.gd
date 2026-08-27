extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    var card := game.player_hand.get_cards()[-1]
    send_click(card.global_position)
    assert(game.turns.selected_card == card)
    assert(game.player_hand.interaction.dragging_card == card)
    var other := game.player_hand.get_cards()[0]
    send_drag(other.global_position)
    await process_frame
    await process_frame
    assert(!other.hovering)
    send_right_click(other.global_position)
    assert(!game.player_hand.interaction.dragging_card)
    assert(!game.turns.selected_card)
    for _frame in 20:
        await process_frame
    send_drag(Vector2(100, 500))
    await process_frame
    var dragged := game.player_hand.get_cards()[-1]
    var target := game.board.get_row_slots(Board.PLAYER_ROW)[2]
    send_button(dragged.global_position, true)
    var desired_position := target.global_position + Vector2(110, 0)
    var drop_point := desired_position - game.player_hand.interaction.drag_offset
    dragged.global_position = desired_position
    game.board._process(0.0)
    assert(game.board.highlighted_target == target)
    game.player_hand.interaction.drag_start_time = 0
    send_button(drop_point, false)
    assert(game.board.get_row_slots(Board.PLAYER_ROW)[0].get_card() == dragged)
    for _frame in 20:
        await process_frame
    verify_invalid_drop()
    quit()

func verify_invalid_drop() -> void:
    var card := game.player_hand.get_cards()[-1]
    send_button(card.global_position, true)
    send_drag(Vector2(100, 500))
    game.player_hand.interaction.drag_start_time = 0
    send_button(Vector2(100, 500), false)
    assert(card.get_parent() == game.player_hand)
    assert(!card.dragging)
    game.player_hand.interaction.update_hover(card.global_position)
    assert(!card.hovering)
    assert(!game.turns.selected_card)

func send_right_click(point: Vector2) -> void:
    var event := InputEventMouseButton.new()
    event.position = point
    event.global_position = point
    event.button_index = MOUSE_BUTTON_RIGHT
    event.pressed = true
    game.get_viewport().push_input(event, true)

func send_drag(point: Vector2) -> void:
    var event := InputEventMouseMotion.new()
    event.position = point
    event.global_position = point
    event.button_mask = MOUSE_BUTTON_MASK_LEFT
    game.get_viewport().push_input(event, true)

func send_click(point: Vector2) -> void:
    send_button(point, true)
    send_button(point, false)

func send_button(point: Vector2, pressed: bool) -> void:
    var event := InputEventMouseButton.new()
    event.position = point
    event.global_position = point
    event.button_index = MOUSE_BUTTON_LEFT
    event.pressed = pressed
    game.get_viewport().push_input(event, true)
