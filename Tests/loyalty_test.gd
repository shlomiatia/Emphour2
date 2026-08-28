extends SceneTree

var game: CardBattle

func _initialize() -> void:
    run_test()

func run_test() -> void:
    CampaignState.start_in_act_2 = true
    CampaignState.reset()
    game = load("res://Scenes/Battlefield/Battlefield.tscn").instantiate()
    root.add_child(game)
    await game.battle_ready
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)
    add_foreign_card(CampaignState.Faction.ENGLISH)
    add_foreign_card(CampaignState.Faction.HRE)
    verify_foreign_eligibility()
    verify_positive_loyalty_skip()
    verify_boss_loyalty()
    quit()

func add_foreign_card(faction: CampaignState.Faction) -> void:
    game.player_hand.add_card(CardFactory.create("Archer", GameRules.Side.PLAYER, faction))

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

func verify_boss_loyalty() -> void:
    CampaignState.declare_war(CampaignState.Faction.ENGLISH)
    CampaignState.prepare_act_2_boss()
    var factions := CampaignState.negative_foreign_factions()
    assert(factions.has(CampaignState.Faction.ENGLISH))
    assert(factions.has(CampaignState.Faction.HRE))
