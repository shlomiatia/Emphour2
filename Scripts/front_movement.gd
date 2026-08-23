class_name FrontMovement extends Node

var board: Board

func setup(game_board: Board) -> void:
    board = game_board

func advance(winner: int) -> Dictionary:
    var loser := GameRules.other(winner)
    var cards := [board.get_cards(winner), board.get_cards(loser)]
    var loser_row := board.get_side_row(loser)
    var target := loser_row + (-1 if winner == GameRules.Side.PLAYER else 1)
    detach_cards(cards[0] + cards[1])
    board.set_side_row(winner, loser_row)
    board.set_side_row(loser, target)
    put_cards(cards[0], loser_row)
    var ejected := put_cards(cards[1], target)
    board.refresh_rows()
    return {"finished": board.get_side_row(winner) == (0 if winner == GameRules.Side.PLAYER else 3), "ejected": ejected}

func advance_to_end(winner: int) -> void:
    var loser := GameRules.other(winner)
    var cards := [board.get_cards(winner), board.get_cards(loser)]
    var target := 0 if winner == GameRules.Side.PLAYER else 3
    detach_cards(cards[0] + cards[1])
    board.set_side_row(winner, target)
    board.set_side_row(loser, -1 if winner == GameRules.Side.PLAYER else 4)
    put_cards(cards[0], target)
    for card in cards[1]:
        card.hide()
    board.refresh_rows()

func detach_cards(cards: Array[Card]) -> void:
    for card in cards:
        card.reparent(board)

func put_cards(cards: Array[Card], row: int) -> Array[Card]:
    if row < 0 || row >= Board.ROW_COUNT:
        return cards
    var slots := board.get_row_slots(row)
    for index in cards.size():
        slots[index].place(cards[index])
    return []
