class_name FrontMovement extends Node

var board: Board

func setup(game_board: Board) -> void:
    board = game_board

func advance(winner: int) -> Dictionary:
    var loser := other_side(winner)
    var winner_row := board.get_side_row(winner)
    var loser_row := board.get_side_row(loser)
    var next_row := loser_row + direction(winner)
    var winning_cards := take_row(winner_row)
    var losing_cards := take_row(loser_row)
    board.set_side_row(winner, loser_row)
    board.set_side_row(loser, next_row)
    put_cards(winning_cards, loser_row)
    if next_row >= 0 && next_row < Board.ROW_COUNT:
        put_cards(losing_cards, next_row)
    else:
        retreat_cards(losing_cards, loser)
    board.refresh_rows()
    return {"finished": next_row < 0 || next_row >= Board.ROW_COUNT}

func advance_to_end(winner: int) -> void:
    var loser := other_side(winner)
    var end_row := 0 if winner == GameRules.Side.PLAYER else Board.ROW_COUNT - 1
    var winning_cards := take_row(board.get_side_row(winner))
    var losing_cards := take_row(board.get_side_row(loser))
    board.set_side_row(winner, end_row)
    board.set_side_row(loser, -1 if winner == GameRules.Side.PLAYER else Board.ROW_COUNT)
    put_cards(winning_cards, end_row)
    retreat_cards(losing_cards, loser)
    board.refresh_rows()

func take_row(row: int) -> Array[Dictionary]:
    var cards: Array[Dictionary]
    if row < 0 || row >= Board.ROW_COUNT:
        return cards
    for slot in board.get_row_slots(row):
        if slot.get_card():
            cards.append({"card": slot.get_card(), "column": slot.column})
            slot.get_card().reparent(board)
    return cards

func put_cards(cards: Array[Dictionary], row: int) -> void:
    var slots := board.get_row_slots(row)
    for entry in cards:
        slots[entry["column"]].place(entry["card"])

func retreat_cards(cards: Array[Dictionary], side: int) -> void:
    for entry in cards:
        entry["card"].retreat_out(side)

func direction(winner: int) -> int:
    return -1 if winner == GameRules.Side.PLAYER else 1

func other_side(side: int) -> int:
    return GameRules.Side.ENEMY if side == GameRules.Side.PLAYER else GameRules.Side.PLAYER
