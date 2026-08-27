class_name LoyaltyDeckCandidates extends RefCounted

var game: CardBattle
var candidates: Array[Dictionary]
var pending: Array[Dictionary]
var active := false

func setup(card_battle: CardBattle) -> void:
    game = card_battle

func capture(group: String) -> void:
    active = true
    candidates.clear()
    pending.clear()
    for index in game.player_draw_pile.size():
        var name := game.player_draw_pile[index]
        var candidate := {"index": index, "name": name, "eligible": RewardRules.belongs_to(name, group), "card": null}
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
    game.player_draw_pile.remove_at(index)
    game.player_deck.set_card_count(game.player_draw_pile.size())
    return true

func draw_replacement() -> Card:
    if pending.is_empty():
        return null
    var candidate: Dictionary = pending.pop_back()
    var card := game.draw_card(GameRules.Side.PLAYER)
    candidate["card"] = card
    return card
