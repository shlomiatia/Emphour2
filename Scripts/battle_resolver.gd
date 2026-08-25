class_name BattleResolver extends Node

var game: CardBattle

func setup(card_game: CardBattle) -> void:
    game = card_game

func resolve() -> void:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var used_defences: Array[Card]
    var defeated: Array[Card]
    var attackers := player_cards + enemy_cards
    for attacker in attackers:
        await resolve_attack(attacker, player_cards, enemy_cards, used_defences, defeated)
    for card in defeated:
        await game.defeat_card(card)

func update_preview() -> void:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var player_losses := potential_losses(enemy_cards, player_cards)
    var enemy_losses := potential_losses(player_cards, enemy_cards)
    game.set_losses(player_losses, enemy_losses)
    if !game.battle_state.active:
        game.preview_balance(total_strength(player_cards) - total_strength(enemy_cards))

func strength_difference() -> int:
    return total_strength(game.board.get_cards(GameRules.Side.PLAYER)) - total_strength(game.board.get_cards(GameRules.Side.ENEMY))

func resolve_attack(attacker: Card, player_cards: Array[Card], enemy_cards: Array[Card], used: Array[Card], defeated: Array[Card]) -> void:
    if attacker.data.attack == 0:
        return
    var opponents := enemy_cards if attacker.side == GameRules.Side.PLAYER else player_cards
    var defenders := available_defenders(attacker, opponents, used)
    var defender := await choose_defender(attacker, defenders)
    if defender:
        used.append(defender)
        game.audio.play_block()
        await attacker.attack_card(defender)
        return
    var targets := available_targets(attacker, opponents, used, defeated)
    var target := await choose_target(attacker, targets)
    if target:
        game.audio.play_attack()
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

func available_targets(attacker: Card, cards: Array[Card], used: Array[Card], defeated: Array[Card]) -> Array[Card]:
    return cards.filter(func(card: Card) -> bool: return !defeated.has(card) && (used.has(card) || !can_defend(attacker.data, card.data)))

func choose_target(attacker: Card, cards: Array[Card]) -> Card:
    if cards.is_empty():
        return null
    if attacker.side == GameRules.Side.PLAYER:
        return await game.choose_card(cards, "Choose a card for %s to kill" % attacker.card_name)
    return cards[0]

func can_defend(attacker: CardData, defender: CardData) -> bool:
    return defender.defence > 0 && defender.anti_attack == attacker.attack_type

func total_strength(cards: Array[Card]) -> int:
    return cards.reduce(func(sum: int, card: Card) -> int: return sum + card.data.strength, 0)

func potential_losses(attackers: Array[Card], defenders: Array[Card]) -> int:
    var losses := 0
    for type in [CardData.AttackType.MISSILE, CardData.AttackType.CAVALRY]:
        losses += maxi(total_attack(attackers, type) - total_defence(defenders, type), 0)
    return mini(losses, defenders.size())

func total_attack(cards: Array[Card], type: CardData.AttackType) -> int:
    return cards.filter(func(card: Card) -> bool: return card.data.attack_type == type).reduce(func(sum: int, card: Card) -> int: return sum + card.data.attack, 0)

func total_defence(cards: Array[Card], type: CardData.AttackType) -> int:
    return cards.filter(func(card: Card) -> bool: return card.data.anti_attack == type).reduce(func(sum: int, card: Card) -> int: return sum + card.data.defence, 0)
