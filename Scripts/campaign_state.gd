class_name CampaignState extends RefCounted

enum Faction { FRANKS, REBELS, ENGLISH, HRE }
enum Arc { FRANCE, FOREIGN_RELATIONS }
enum Relation { WAR = -5, HOSTILE, CLOSE_BORDERS, DIPLOMATIC_PROTEST, TRADE_EMBARGO, NEUTRAL, TRADE_PACT, NON_AGGRESSION_PACT, OPEN_BORDERS, DEFENSIVE_ALLIANCE, MILITARY_ALLIANCE }

const STARTING_DECK: Array[String] = ["Archer", "Mantlet", "Stakes", "Light Cavalry", "Militia", "Militia", "Militia", "Militia", "Militia", "Militia"]
const ACT_2_STARTING_DECK: Array[String] = ["Archer", "Crossbowman", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman", "Foot Knight", "Lancer", "Heavy Cavalry", "Knight"]
const CITY_SLOTS := {"Act 1 City 1": 3, "Act 1 City 2": 3, "Act 1 City 3": 4, "Act 1 City 4": 4, "Act 1 City 5": 5, "Act 1 City 6": 5, "Act 1 Boss": 5, "Act 2 City 1": 3, "Act 2 City 2": 3, "Act 2 City 3": 4, "Act 2 City 4": 4, "Act 2 City 5": 5, "Act 2 City 6": 5, "Act 2 Boss": 5}

static var selected_city := ""
static var start_in_act_2 := false
static var player_deck: Array[CampaignCard] = create_frank_deck(STARTING_DECK)
static var loyalty := {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
static var city_owner := create_act_1_owners()
static var arc := Arc.FRANCE
static var foreign_loyalty := {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
static var act_2_progress := 0
static var act_2_boss_defeated := false

static func create_frank_deck(names: Array[String]) -> Array[CampaignCard]:
    return create_deck(names, Faction.FRANKS)

static func create_deck(names: Array[String], faction: Faction) -> Array[CampaignCard]:
    var deck: Array[CampaignCard]
    for card_name in names:
        deck.append(CampaignCard.new(card_name, faction))
    return deck

static func create_act_2_deck() -> Array[CampaignCard]:
    var deck: Array[CampaignCard]
    for index in ACT_2_STARTING_DECK.size():
        deck.append(CampaignCard.new(ACT_2_STARTING_DECK[index], Faction.ENGLISH if index % 2 == 0 else Faction.HRE))
    return deck

static func create_act_1_owners() -> Dictionary:
    var owners := {}
    for index in 6:
        owners[act_1_city_id(index + 1)] = Faction.REBELS
    return owners

static func copy_deck(deck: Array[CampaignCard]) -> Array[CampaignCard]:
    var result: Array[CampaignCard]
    for entry in deck:
        result.append(entry.copy())
    return result

static func act_1_city_id(index: int) -> String:
    return "Act 1 City %d" % index

static func act_2_city_id(index: int) -> String:
    return "Act 2 City %d" % index

static func is_act_1_boss() -> bool:
    return selected_city == "Act 1 Boss"

static func is_act_2_boss() -> bool:
    return selected_city == "Act 2 Boss"

static func is_final_battle() -> bool:
    return is_act_1_boss()

static func is_act_2() -> bool:
    return arc == Arc.FOREIGN_RELATIONS

static func foreign_relations_active() -> bool:
    return is_act_2()

static func battle_slot_count() -> int:
    return CITY_SLOTS.get(selected_city, 3)

static func faction_at_war() -> Faction:
    for faction in foreign_loyalty:
        if foreign_loyalty[faction] == Relation.WAR:
            return faction
    return Faction.REBELS

static func battlefield_faction() -> Faction:
    if !is_act_2():
        return Faction.REBELS
    return other_foreign_faction(faction_at_war()) if is_act_2_boss() else faction_at_war()

static func map_city_id(base_id: String) -> String:
    if base_id != act_1_city_id(1):
        return base_id
    if is_act_2() && act_2_progress == 6 && !act_2_boss_defeated:
        return "Act 2 Boss"
    if !is_act_2() && city_owner[act_1_city_id(1)] == Faction.REBELS && city_owner.values().count(Faction.FRANKS) == city_owner.size() - 1:
        return "Act 1 Boss"
    return base_id

static func map_owner(base_id: String, faction: Faction, route_index: int) -> Faction:
    var city_id := map_city_id(base_id)
    if city_id == "Act 1 Boss":
        return Faction.REBELS
    if city_id == "Act 2 Boss":
        return Faction.FRANKS if act_2_boss_defeated else battlefield_faction()
    if faction != Faction.FRANKS && is_act_2() && faction == faction_at_war() && route_index <= act_2_progress:
        return Faction.FRANKS
    return city_owner.get(city_id, faction)

static func can_declare_war(faction: Faction, route_index: int) -> bool:
    return is_act_2() && act_2_progress == 0 && faction_at_war() == Faction.REBELS && route_index == 1

static func can_attack_act_2(faction: Faction, route_index: int) -> bool:
    if !is_act_2() || faction != faction_at_war():
        return false
    return route_index == act_2_progress + 1 && route_index <= 6

static func capture_selected_city() -> void:
    if is_act_2():
        capture_act_2_city()
        return
    if is_act_1_boss():
        start_act_2()
        return
    if city_owner.has(selected_city):
        city_owner[selected_city] = Faction.FRANKS
    if city_owner.values().all(func(owner: int) -> bool: return owner == Faction.FRANKS):
        city_owner[act_1_city_id(1)] = Faction.REBELS

static func capture_act_2_city() -> void:
    if is_act_2_boss():
        act_2_boss_defeated = true
        return
    act_2_progress = maxi(act_2_progress, city_number(selected_city))

static func city_number(city_id: String) -> int:
    return int(city_id.get_slice(" ", 3))

static func crossbowman_unlocked(city_id := selected_city) -> bool:
    return is_act_2() || city_number(city_id) >= 4

static func change_loyalty(group: String, amount: int) -> void:
    loyalty[group] = loyalty_after(group, amount)

static func loyalty_after(group: String, amount: int) -> int:
    return clampi(loyalty[group] + amount, Relation.WAR, Relation.MILITARY_ALLIANCE)

static func loyal_group() -> String:
    return "Peasants" if loyalty["Peasants"] >= loyalty["Nobility"] else "Nobility"

static func disloyal_group() -> String:
    return "Nobility" if loyal_group() == "Peasants" else "Peasants"

static func negative_foreign_factions() -> Array[int]:
    var factions: Array[int]
    for faction in foreign_loyalty:
        if foreign_loyalty[faction] < 0:
            factions.append(faction)
    return factions

static func declare_war(faction: Faction) -> void:
    if !can_declare_war(faction, 1):
        return
    foreign_loyalty[faction] = Relation.WAR
    foreign_loyalty[other_foreign_faction(faction)] = Relation.MILITARY_ALLIANCE
    selected_city = act_2_city_id(1)

static func other_foreign_faction(faction: Faction) -> Faction:
    return Faction.HRE if faction == Faction.ENGLISH else Faction.ENGLISH

static func faction_name(faction: Faction) -> String:
    return "English" if faction == Faction.ENGLISH else "Holy Roman Empire" if faction == Faction.HRE else "Franks" if faction == Faction.FRANKS else "Rebels"

static func faction_color(faction: Faction) -> Color:
    match faction:
        Faction.REBELS: return Color("#f5eee2")
        Faction.ENGLISH: return Color("#e43b44")
        Faction.HRE: return Color("#feae34")
    return Color("#0099db")

static func start_act_2() -> void:
    arc = Arc.FOREIGN_RELATIONS
    player_deck = create_act_2_deck()
    foreign_loyalty = {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
    act_2_progress = 0
    act_2_boss_defeated = false
    for city in city_owner:
        city_owner[city] = Faction.FRANKS

static func reset() -> void:
    selected_city = ""
    player_deck = create_frank_deck(STARTING_DECK)
    loyalty = {"Peasants": Relation.NEUTRAL, "Nobility": Relation.NEUTRAL}
    city_owner = create_act_1_owners()
    arc = Arc.FRANCE
    foreign_loyalty = {Faction.ENGLISH: Relation.NEUTRAL, Faction.HRE: Relation.NEUTRAL}
    act_2_progress = 0
    act_2_boss_defeated = false
    if start_in_act_2:
        start_act_2()
