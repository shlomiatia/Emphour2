extends SceneTree

var reward: RewardScreen

func _initialize() -> void:
	run_test()

func run_test() -> void:
	Engine.time_scale = 30.0
	CampaignState.reset()
	verify_rules()
	await open_reward()
	verify_options()
	verify_tooltip()
	await verify_choice()
	quit()

func open_reward() -> void:
	CampaignState.selected_city = "Rouen"
	CampaignState.selected_front = CampaignState.Faction.ENGLAND
	var game := load("res://Scenes/Game/Game.tscn").instantiate() as CardGame
	root.add_child(game)
	current_scene = game
	await process_frame
	game.finish_game(GameRules.Side.PLAYER)
	for frame in 60:
		await process_frame
	reward = current_scene as RewardScreen
	assert(reward)

func verify_rules() -> void:
	var deck: Array[String] = ["Archer", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman"]
	for group in ["Peasants", "Nobility"]:
		for loyalty in 6:
			var offer := RewardRules.create_offer(group, loyalty, deck)
			var rule: Array = RewardRules.REWARDS[group][loyalty]
			assert(RewardRules.get_group_cards(group, rule[1]).has(offer["new"]))
			if rule[0] > 0:
				assert(RewardRules.TIERS[rule[0]].has(offer["old"]))

func verify_options() -> void:
	var peasants: Dictionary = reward.offers["Peasants"]
	var nobility: Dictionary = reward.offers["Nobility"]
	assert(peasants["old"].is_empty())
	assert(RewardRules.get_group_cards("Peasants", 1).has(peasants["new"]))
	assert(RewardRules.TIERS[1].has(nobility["old"]))
	assert(RewardRules.get_group_cards("Nobility", 2).has(nobility["new"]))

func verify_tooltip() -> void:
	reward._on_option_hovered("Nobility")
	assert(reward.tooltip.visible)
	assert(reward.current_labels[0].text == "Neutral")
	assert(reward.target_labels[0].text == "Uneasy")
	assert(reward.target_labels[1].text == "At Ease")

func verify_choice() -> void:
	var offer: Dictionary = reward.offers["Nobility"]
	var old_count := CampaignState.player_deck.count(offer["old"])
	await reward._on_option_chosen("Nobility")
	await process_frame
	assert(CampaignState.player_deck.count(offer["old"]) == old_count - 1)
	assert(CampaignState.player_deck.has(offer["new"]))
	assert(CampaignState.loyalty["Peasants"] == -1)
	assert(CampaignState.loyalty["Nobility"] == 1)
	assert(CampaignState.city_owner["Rouen"] == CampaignState.Faction.FRANKS)
	assert(CampaignState.relations[CampaignState.Faction.ENGLAND] == CampaignState.Relation.TRADE_EMBARGO)
	assert(CampaignState.relations[CampaignState.Faction.HOLY_ROMAN_EMPIRE] == CampaignState.Relation.TRADE_PACT)
	assert(current_scene is CampaignMap)
