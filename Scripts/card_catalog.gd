class_name CardCatalog extends RefCounted

const CARDS: Array[String] = [
    "Archer", "Crossbowman", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman",
    "Swordman", "Spearman", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"
]

static func get_value(card_name: String) -> float:
    if card_name == "Crossbowman":
        return 2.5
    var data := get_data(card_name)
    return float(data.strength + data.attack + data.defence)

static func get_data(card_name: String) -> CardData:
    match card_name:
        "Archer":
            return create_attacker(card_name, 0, CardData.AttackType.MISSILE)
        "Crossbowman":
            return create_attacker(card_name, 0, CardData.AttackType.ARMOR_PIERCING)
        "Mantlet":
            return create_defender(card_name, CardData.AttackType.MISSILE)
        "Stakes":
            return create_defender(card_name, CardData.AttackType.CAVALRY)
        "Horse Archer":
            return create_horse_archer()
        "Light Cavalry":
            return create_attacker(card_name, 1, CardData.AttackType.CAVALRY)
        "Axeman":
            return create_unit(card_name, 2)
        "Swordman":
            return create_guard(card_name, CardData.AttackType.MISSILE)
        "Spearman":
            return create_guard(card_name, CardData.AttackType.CAVALRY)
        "Foot Knight":
            return create_armored(card_name, 2)
        "Lancer":
            return create_attacker(card_name, 2, CardData.AttackType.CAVALRY)
        "Heavy Cavalry":
            return create_armored_cavalry(card_name, 1)
        "Knight":
            return create_armored_cavalry(card_name, 2)
    return create_unit("Militia", 1)

static func create_horse_archer() -> CardData:
    var data := create_attacker("Horse Archer", 0, CardData.AttackType.MISSILE)
    data.defence = 1
    data.anti_attack = CardData.AttackType.CAVALRY
    return data

static func create_armored_cavalry(card_name: String, strength: int) -> CardData:
    var data := create_attacker(card_name, strength, CardData.AttackType.CAVALRY)
    data.defence = 1
    data.armored = true
    return data

static func create_armored(card_name: String, strength: int) -> CardData:
    var data := create_unit(card_name, strength)
    data.defence = 1
    data.armored = true
    return data

static func create_attacker(card_name: String, strength: int, attack_type: CardData.AttackType) -> CardData:
    var data := create_unit(card_name, strength)
    data.attack = 1
    data.attack_type = attack_type
    return data

static func create_defender(card_name: String, attack_type: CardData.AttackType) -> CardData:
    return create_guard(card_name, attack_type, 0)

static func create_guard(card_name: String, attack_type: CardData.AttackType, strength := 1) -> CardData:
    var data := create_unit(card_name, strength)
    data.defence = 1
    data.anti_attack = attack_type
    return data

static func create_unit(card_name: String, strength: int) -> CardData:
    var data := CardData.new()
    data.name = card_name
    data.strength = strength
    data.attack_type = CardData.AttackType.NONE
    data.anti_attack = CardData.AttackType.NONE
    return data
