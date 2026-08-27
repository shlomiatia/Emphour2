extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.start_act_2()
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)
    verify_foreign_eligibility()
    verify_positive_loyalty_skip()
    quit()

func verify_foreign_eligibility() -> void:
    var factions: Array[int] = [CampaignState.Faction.ENGLISH]
    var cards := game.loyalty_events.eligible_foreign_cards(factions)
    assert(!cards.is_empty())
    assert(cards.all(func(card: Card) -> bool: return card.faction == CampaignState.Faction.ENGLISH))
    assert(game.loyalty_events.eligible_foreign_cards([CampaignState.Faction.HRE]).all(func(card: Card) -> bool: return card.faction == CampaignState.Faction.HRE))

func verify_positive_loyalty_skip() -> void:
    CampaignState.foreign_loyalty[CampaignState.Faction.ENGLISH] = CampaignState.Relation.MILITARY_ALLIANCE
    assert(CampaignState.negative_foreign_factions().is_empty())
    game.loyalty_events.run_foreign_events()
    assert(!game.loyalty_events.waiting)
