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
