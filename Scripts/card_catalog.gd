class_name CardCatalog extends RefCounted

static func get_data(card_name: String) -> CardData:
    match card_name:
        "Archer":
            return create_archer()
        "Mantlet":
            return create_defence("Mantlet", CardData.AttackType.MISSILE)
        "Stakes":
            return create_defence("Stakes", CardData.AttackType.CAVALRY)
        _:
            return create_militia()

static func create_archer() -> CardData:
    var data := create_card("Archer")
    data.attack = 1
    data.attack_type = CardData.AttackType.MISSILE
    return data

static func create_defence(card_name: String, attack_type: CardData.AttackType) -> CardData:
    var data := create_card(card_name)
    data.defence = 1
    data.anti_attack = attack_type
    return data

static func create_militia() -> CardData:
    var data := create_card("Militia")
    data.strength = 1
    return data

static func create_card(card_name: String) -> CardData:
    var data := CardData.new()
    data.name = card_name
    data.attack_type = CardData.AttackType.NONE
    data.anti_attack = CardData.AttackType.NONE
    return data
