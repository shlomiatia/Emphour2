class_name LoyaltyDeckCandidates extends RefCounted

var game: CardBattle
var candidates: Array[Dictionary]
var pending: Array[Dictionary]
var active := false

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func capture_group(group: String) -> void:
    capture(func(entry: CampaignCard) -> bool: return RewardRules.belongs_to(entry.card_name, group))

func capture_factions(factions: Array[int]) -> void:
    capture(func(entry: CampaignCard) -> bool: return factions.has(entry.faction))

func capture(filter: Callable) -> void:
    active = true
    candidates.clear()
    pending.clear()
    for index in game.player_draw_pile.size():
        var entry := game.player_draw_pile[index]
        var candidate := {"entry": entry, "name": entry.card_name, "eligible": filter.call(entry), "card": null}
        candidates.append(candidate)
        pending.append(candidate)

func get_eligible() -> Array[Dictionary]:
    var result: Array[Dictionary]
    result.assign(candidates.filter(func(candidate: Dictionary) -> bool: return candidate["eligible"]))
    return result

func get_card(candidate: Dictionary) -> Card:
    var card := candidate["card"] as Card
    return card if is_instance_valid(card) else null

func remove_from_deck(candidate: Dictionary) -> bool:
    var index := pending.find(candidate)
    if index < 0:
        return false
    pending.remove_at(index)
    game.player_draw_pile.erase(candidate["entry"])
    game.player_deck.set_card_count(game.player_draw_pile.size())
    return true

func draw_replacement() -> Card:
    if pending.is_empty():
        return null
    var candidate: Dictionary = pending.pop_back()
    var card := game.draw_card(GameRules.Side.PLAYER)
    candidate["card"] = card
    return card
