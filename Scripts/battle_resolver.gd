class_name BattleResolver extends Node

var game: CardGame

func setup(card_game: CardGame) -> void:
    game = card_game

func resolve() -> int:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var used_defences: Array[Card]
    var defeated: Array[Card]
    var attackers := player_cards + enemy_cards
    update_strengths()
    for attacker in attackers:
        await resolve_attack(attacker, player_cards, enemy_cards, used_defences, defeated)
    for card in defeated:
        await game.defeat_card(card)
    return update_strengths()

func update_strengths() -> int:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var strengths := [total_strength(player_cards), total_strength(enemy_cards)]
    var player_losses := potential_losses(enemy_cards, player_cards)
    var enemy_losses := potential_losses(player_cards, enemy_cards)
    game.set_strengths(strengths[0], strengths[1], player_losses, enemy_losses)
    return compare_strengths(strengths)

func empty_hand_winner() -> int:
    if game.player_hand.get_card_count() == 0 && game.enemy_hand.get_card_count() > 0:
        return winning_side(GameRules.Side.ENEMY)
    if game.enemy_hand.get_card_count() == 0 && game.player_hand.get_card_count() > 0:
        return winning_side(GameRules.Side.PLAYER)
    return -1

func winning_side(side: int) -> int:
    var cards := game.board.get_cards(side)
    var opponents := game.board.get_cards(GameRules.other(side))
    if total_strength(cards) > total_strength(opponents) && potential_losses(opponents, cards) == 0:
        return side
    return -1

func resolve_attack(attacker: Card, player_cards: Array[Card], enemy_cards: Array[Card], used: Array[Card], defeated: Array[Card]) -> void:
    if attacker.data.attack == 0:
        return
    var opponents := enemy_cards if attacker.side == GameRules.Side.PLAYER else player_cards
    var defenders := available_defenders(attacker, opponents, used)
    var defender := await choose_defender(attacker, defenders)
    if defender:
        used.append(defender)
        game.play_block_sound()
        await attacker.attack_card(defender)
        await defender.defend()
        return
    var targets := available_targets(attacker, opponents, defeated)
    var target := await choose_target(attacker, targets)
    if target:
        game.play_attack_sound()
        await attacker.attack_card(target)
        defeated.append(target)

func available_defenders(attacker: Card, cards: Array[Card], used: Array[Card]) -> Array[Card]:
    return cards.filter(func(card: Card) -> bool: return !used.has(card) && can_defend(attacker.data, card.data))

func choose_defender(attacker: Card, cards: Array[Card]) -> Card:
    if cards.is_empty():
        return null
    if attacker.side == GameRules.Side.ENEMY:
        return await game.choose_card(cards, "Choose a card to defend against %s" % attacker.card_name)
    return cards[0]

func available_targets(attacker: Card, cards: Array[Card], defeated: Array[Card]) -> Array[Card]:
    return cards.filter(func(card: Card) -> bool: return !defeated.has(card) && !can_defend(attacker.data, card.data))

func choose_target(attacker: Card, cards: Array[Card]) -> Card:
    if cards.is_empty():
        return null
    if attacker.side == GameRules.Side.PLAYER:
        return await game.choose_card(cards, "Choose a card for %s to kill" % attacker.card_name)
    return cards[0]

func can_defend(attacker: CardData, defender: CardData) -> bool:
    if defender.defence == 0:
        return false
    if defender.anti_attack == attacker.attack_type:
        return true
    if defender.defence_type == CardData.DefenceType.NONE:
        return false
    return !attacker.anti_defences.has(defender.defence_type)

func total_strength(cards: Array[Card]) -> int:
    return cards.reduce(func(sum: int, card: Card) -> int: return sum + card.data.strength, 0)

func potential_losses(attackers: Array[Card], defenders: Array[Card]) -> int:
    return maxi(total_attack(attackers) - total_relevant_defence(attackers, defenders), 0)

func total_attack(cards: Array[Card]) -> int:
    return cards.reduce(func(sum: int, card: Card) -> int: return sum + card.data.attack, 0)

func total_relevant_defence(attackers: Array[Card], defenders: Array[Card]) -> int:
    return defenders.filter(func(defender: Card) -> bool: return attackers.any(func(attacker: Card) -> bool: return can_defend(attacker.data, defender.data))).reduce(func(sum: int, card: Card) -> int: return sum + card.data.defence, 0)

func compare_strengths(strengths: Array) -> int:
    if strengths[0] == strengths[1]:
        return -1
    return GameRules.Side.PLAYER if strengths[0] > strengths[1] else GameRules.Side.ENEMY
