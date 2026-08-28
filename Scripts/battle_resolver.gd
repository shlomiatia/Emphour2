class_name BattleResolver extends RefCounted

var game: CardBattle
var matcher := DefenceMatcher.new()

func setup(card_game: CardBattle) -> void:
    game = card_game

func resolve() -> void:
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var used_defences: Array[Card]
    var defeated: Array[Card]
    var attackers := player_cards + enemy_cards
    for index in attackers.size():
        await resolve_attack(attackers[index], player_cards, enemy_cards, used_defences, defeated, remaining_attackers(attackers, index))
    for card in defeated:
        await game.defeat_card(card)

func update_preview() -> void:
    if game.battle_state.active:
        return
    var player_cards := game.board.get_cards(GameRules.Side.PLAYER)
    var enemy_cards := game.board.get_cards(GameRules.Side.ENEMY)
    var player_losses := potential_losses(enemy_cards, player_cards)
    var enemy_losses := potential_losses(player_cards, enemy_cards)
    game.set_losses(player_losses, enemy_losses)
    game.preview_balance(total_strength(player_cards) - total_strength(enemy_cards))

func strength_difference() -> int:
    return total_strength(game.board.get_cards(GameRules.Side.PLAYER)) - total_strength(game.board.get_cards(GameRules.Side.ENEMY))

func resolve_attack(attacker: Card, player_cards: Array[Card], enemy_cards: Array[Card], used: Array[Card], defeated: Array[Card], remaining: Array[Card]) -> void:
    if attacker.data.attack == 0:
        return
    var opponents := enemy_cards if attacker.side == GameRules.Side.PLAYER else player_cards
    var defenders := available_defenders(attacker, opponents, used)
    var defender := await choose_defender(attacker, defenders, opponents, used, remaining)
    if defender:
        used.append(defender)
        game.audio.play_block()
        game.shake_camera()
        await attacker.attack_card(defender)
        return
    var targets := available_targets(attacker, opponents, defeated)
    var target := await choose_target(attacker, targets)
    if target:
        game.audio.play_attack()
        game.shake_camera()
        await attacker.attack_card(target)
        defeated.append(target)

func remaining_attackers(cards: Array[Card], start: int) -> Array[Card]:
    var result: Array[Card]
    for index in range(start, cards.size()):
        result.append(cards[index])
    return result

func available_defenders(attacker: Card, cards: Array[Card], used: Array[Card]) -> Array[Card]:
    return matcher.available_defenders(attacker.data, cards, used)

func choose_defender(attacker: Card, cards: Array[Card], opponents: Array[Card], used: Array[Card], attackers: Array[Card]) -> Card:
    if cards.is_empty():
        return null
    if attacker.side == GameRules.Side.ENEMY:
        return await game.choose_card(cards, "Choose a card to defend against %s" % CardCatalog.display_name(attacker.card_name))
    var defenders: Array[Card] = opponents.filter(func(card: Card) -> bool: return !used.has(card))
    var player_attackers: Array[Card] = attackers.filter(func(card: Card) -> bool: return card.side == GameRules.Side.PLAYER && card.data.attack > 0)
    return matcher.choose(attacker, cards, player_attackers, defenders)

func available_targets(attacker: Card, cards: Array[Card], defeated: Array[Card]) -> Array[Card]:
    return matcher.available_targets(attacker.data, cards, defeated)

func choose_target(attacker: Card, cards: Array[Card]) -> Card:
    if cards.is_empty():
        return null
    if attacker.side == GameRules.Side.PLAYER:
        return await game.choose_card(cards, "Choose a card for %s to kill" % CardCatalog.display_name(attacker.card_name))
    var chosen: Card = cards.pick_random()
    return chosen

func can_defend(attacker: CardData, defender: CardData) -> bool:
    return matcher.can_defend(attacker, defender)

func total_strength(cards: Array[Card]) -> int:
    return cards.reduce(func(sum: int, card: Card) -> int: return sum + card.data.strength, 0)

func potential_losses(attackers: Array[Card], defenders: Array[Card]) -> int:
    return matcher.preview_losses(attackers, defenders)
