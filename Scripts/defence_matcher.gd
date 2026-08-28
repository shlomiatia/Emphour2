class_name DefenceMatcher extends RefCounted

func choose(attacker: Card, options: Array[Card], attackers: Array[Card], defenders: Array[Card]) -> Card:
    var chosen: Card
    var maximum := -1
    for defender in options:
        var score := 1 + maximum_matches(attackers.filter(func(card: Card) -> bool: return card != attacker), defenders.filter(func(card: Card) -> bool: return card != defender))
        if score > maximum || score == maximum && (!chosen || defender.data.strength < chosen.data.strength):
            chosen = defender
            maximum = score
    return chosen

func maximum_matches(attackers: Array[Card], defenders: Array[Card]) -> int:
    return match_attackers(attackers, defenders, 0, [])

func preview_losses(attackers: Array[Card], defenders: Array[Card]) -> int:
    return preview_attackers(attackers, defenders, 0, [], [])

func preview_attackers(attackers: Array[Card], defenders: Array[Card], index: int, used: Array[Card], defeated: Array[Card]) -> int:
    if index == attackers.size():
        return 0
    var attacker := attackers[index]
    if attacker.data.attack == 0:
        return preview_attackers(attackers, defenders, index + 1, used, defeated)
    var blocks := available_defenders(attacker.data, defenders, used)
    if !blocks.is_empty():
        return preview_blocked(attackers, defenders, index, used, defeated, blocks)
    return preview_targets(attackers, defenders, index, used, defeated, available_targets(attacker.data, defenders, defeated))

func preview_blocked(attackers: Array[Card], defenders: Array[Card], index: int, used: Array[Card], defeated: Array[Card], blocks: Array[Card]) -> int:
    var losses := defenders.size()
    for defender in blocks:
        var next: Array[Card] = used.duplicate()
        next.append(defender)
        losses = mini(losses, preview_attackers(attackers, defenders, index + 1, next, defeated))
    return losses

func preview_targets(attackers: Array[Card], defenders: Array[Card], index: int, used: Array[Card], defeated: Array[Card], targets: Array[Card]) -> int:
    if targets.is_empty():
        return preview_attackers(attackers, defenders, index + 1, used, defeated)
    var losses := defenders.size()
    for target in targets:
        var next: Array[Card] = defeated.duplicate()
        next.append(target)
        losses = mini(losses, 1 + preview_attackers(attackers, defenders, index + 1, used, next))
    return losses

func match_attackers(attackers: Array[Card], defenders: Array[Card], index: int, used: Array[Card]) -> int:
    if index == attackers.size():
        return 0
    var maximum := match_attackers(attackers, defenders, index + 1, used)
    for defender in defenders:
        if !used.has(defender) && can_defend(attackers[index].data, defender.data):
            var next: Array[Card] = used.duplicate()
            next.append(defender)
            maximum = maxi(maximum, 1 + match_attackers(attackers, defenders, index + 1, next))
    return maximum

func can_defend(attacker: CardData, defender: CardData) -> bool:
    return defender.defence > 0 && (defender.armored && attacker.attack_type != CardData.AttackType.ARMOR_PIERCING || defender.anti_attack == attacker.attack_type)

func available_defenders(attacker: CardData, cards: Array[Card], used: Array[Card]) -> Array[Card]:
    return cards.filter(func(card: Card) -> bool: return !used.has(card) && can_defend(attacker, card.data))

func available_targets(attacker: CardData, cards: Array[Card], defeated: Array[Card]) -> Array[Card]:
    return cards.filter(func(card: Card) -> bool: return !defeated.has(card) && !can_defend(attacker, card.data))
