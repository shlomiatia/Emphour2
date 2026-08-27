extends SceneTree

var game: CardBattle
var militia: Card
var mantlet: Card
var selection_checked := false

func _initialize() -> void:
    run_test()

func run_test() -> void:
    Engine.time_scale = 30.0
    CampaignState.reset()
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate() as CardBattle
    root.add_child(game)
    await game.battle_ready
    setup_cards()
    verify_card_input()
    process_frame.connect(select_militia)
    await game.battle.resolve()
    process_frame.disconnect(select_militia)
    assert(selection_checked)
    assert(game.enemy_discard.card_count == 1)
    game.free()
    quit()

func setup_cards() -> void:
    clear_cards()
    var archer_one := add_card("Archer", GameRules.Side.PLAYER)
    var archer_two := add_card("Archer", GameRules.Side.PLAYER)
    mantlet = add_card("Mantlet", GameRules.Side.ENEMY)
    militia = add_card("Militia", GameRules.Side.ENEMY)
    game.board.play_leftmost(archer_one, GameRules.Side.PLAYER)
    game.board.play_leftmost(archer_two, GameRules.Side.PLAYER)
    game.board.play_leftmost(mantlet, GameRules.Side.ENEMY)
    game.board.play_leftmost(militia, GameRules.Side.ENEMY)

func clear_cards() -> void:
    var cards := game.player_hand.get_cards() + game.enemy_hand.get_cards()
    cards += game.board.get_cards(GameRules.Side.PLAYER) + game.board.get_cards(GameRules.Side.ENEMY)
    for card in cards:
        card.free()
    game.turns.pending_enemy = null
    game.turns.accepting_action = false

func add_card(card_name: String, side: int) -> Card:
    var card := game.create_card(card_name, side)
    game.add_child(card)
    return card

func verify_card_input() -> void:
    for node in militia.find_children("*", "Control", true, false):
        assert((node as Control).mouse_filter == Control.MOUSE_FILTER_IGNORE)

func select_militia() -> void:
    if game.selectable_cards.is_empty():
        return
    var names := game.selectable_cards.map(func(card: Card) -> String: return card.card_name)
    assert(names == ["Militia"])
    var slot := militia.get_parent().get_parent() as CardSlot
    assert(slot.targetable)
    assert(game.board.get_target_at(militia.global_position) == slot)
    selection_checked = true
    game.board.target_chosen.emit(slot)
