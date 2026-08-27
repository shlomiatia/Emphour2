class_name BattleDraws extends RefCounted

const DRAW_DELAY := 0.15

var game: CardBattle

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func setup_piles(player_names: Array[String], enemy_names: Array[String]) -> void:
    setup_pile(player_names, game.player_draw_pile)
    setup_pile(enemy_names, game.enemy_draw_pile)
    game.player_deck.set_card_count(game.player_draw_pile.size())
    game.enemy_deck_pile.set_card_count(game.enemy_draw_pile.size())

func setup_pile(names: Array[String], pile: Array[String]) -> void:
    pile.assign(names)
    pile.shuffle()

func draw_opening_hands() -> void:
    await game.get_tree().create_timer(DRAW_DELAY).timeout
    var cards: Array[Card]
    while opening_draw_needed():
        cards = draw_opening_beat()
        game.audio.play_card()
        await game.get_tree().create_timer(DRAW_DELAY).timeout
    await finish_draws(cards)

func opening_draw_needed() -> bool:
    return game.player_hand.get_card_count() < 5 && !game.player_draw_pile.is_empty() || game.enemy_hand.get_card_count() < 5 && !game.enemy_draw_pile.is_empty()

func draw_opening_beat() -> Array[Card]:
    var cards: Array[Card]
    if game.player_hand.get_card_count() < 5 && !game.player_draw_pile.is_empty():
        cards.append(draw_card(GameRules.Side.PLAYER))
    if game.enemy_hand.get_card_count() < 5 && !game.enemy_draw_pile.is_empty():
        cards.append(draw_card(GameRules.Side.ENEMY))
    return cards

func finish_draws(cards: Array[Card]) -> void:
    for card in cards:
        if card.moving:
            await card.draw_finished

func draw_card(side: int) -> Card:
    var pile := get_draw_pile(side)
    if pile.is_empty():
        return null
    var deck := get_deck(side)
    var card := game.create_card(pile.pop_back(), side)
    var hand := game.player_hand if side == GameRules.Side.PLAYER else game.enemy_hand
    hand.add_drawn_card(card, deck)
    deck.set_card_count(pile.size())
    return card

func get_draw_pile(side: int) -> Array[String]:
    return game.player_draw_pile if side == GameRules.Side.PLAYER else game.enemy_draw_pile

func get_deck(side: int) -> CardDeck:
    return game.player_deck if side == GameRules.Side.PLAYER else game.enemy_deck_pile
