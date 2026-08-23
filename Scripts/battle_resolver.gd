class_name BattleResolver extends Node

var game: CardGame

func setup(card_game: CardGame) -> void:
    game = card_game

func resolve() -> int:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var strengths := [total_strength(player_cards), total_strength(enemy_cards)]
    var used_defences: Array[Card]
    var defeated: Array[Card]
    var attackers := player_cards + enemy_cards
    game.set_strengths(strengths[0], strengths[1])
    for attacker in attackers:
        await resolve_attack(attacker, player_cards, enemy_cards, used_defences, defeated)
    for card in defeated:
        game.discard_card(card)
    return compare_strengths(strengths)

func resolve_attack(attacker: Card, player_cards: Array[Card], enemy_cards: Array[Card], used: Array[Card], defeated: Array[Card]) -> void:
    if attacker.data.attack == 0:
        return
    var opponents := enemy_cards if attacker.side == GameRules.Side.PLAYER else player_cards
    var defenders := available_defenders(attacker, opponents, used)
    var defender := await choose_defender(attacker, defenders)
    if defender:
        used.append(defender)
        await attacker.attack_card(defender)
        await defender.defend()
        return
    var targets := available_targets(attacker, opponents, defeated)
    var target := await choose_target(attacker, targets)
    if target:
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

func compare_strengths(strengths: Array) -> int:
    if strengths[0] == strengths[1]:
        return -1
    return GameRules.Side.PLAYER if strengths[0] > strengths[1] else GameRules.Side.ENEMY
