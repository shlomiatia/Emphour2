extends SceneTree

var reward: RewardScreen

func _initialize() -> void:
	run_test()

func run_test() -> void:
	Engine.time_scale = 30.0
	CampaignState.reset()
	verify_rules()
	verify_final_rules()
	verify_final_campaign()
	await open_reward()
	verify_options()
	verify_tooltip()
	await verify_choice()
	quit()

func open_reward() -> void:
	CampaignState.selected_city = "Rouen"
	var game := load("res://Scenes/Battle/Battle.tscn").instantiate() as CardBattle
	root.add_child(game)
	current_scene = game
	await process_frame
	game.battle_state.finish_game(GameRules.Side.PLAYER)
	for frame in 60:
		await process_frame
	reward = current_scene as RewardScreen
	assert(reward)

func verify_rules() -> void:
	var deck: Array[String] = ["Archer", "Mantlet", "Stakes", "Horse Archer", "Light Cavalry", "Axeman", "Swordman", "Spearman"]
	for group in ["Peasants", "Nobility"]:
		for loyalty in 6:
			var offer := RewardRules.create_offer(group, loyalty, deck)
			var rule := RewardRules.get_reward(group, loyalty)
			assert(RewardRules.get_group_cards(group, rule["tier"]).has(offer["new"]))
			if rule["upgrade"] && !offer["old"].is_empty():
				assert(RewardRules.get_upgrade_cards(group, offer["old"], rule["tier"]).has(offer["new"]))
	verify_upgrade_fallback()

func verify_upgrade_fallback() -> void:
	var offer := RewardRules.create_offer("Nobility", 3, ["Horse Archer"])
	assert(offer["old"] == "Horse Archer")
	assert(RewardRules.get_group_cards("Nobility", 3).has(offer["new"]))

func verify_final_rules() -> void:
	var deck: Array[String] = ["Archer", "Mantlet", "Axeman"]
	var knight := RewardRules.create_final_offer("Nobility", false, deck)
	var upgrade := RewardRules.create_final_offer("Nobility", true, deck)
	var peasants := RewardRules.create_final_offer("Peasants", false, deck)
	assert(knight["new"] == "Knight")
	assert(RewardRules.TIERS[1].has(upgrade["old"]) && upgrade["new"] == "Knight")
	assert(RewardRules.get_group_cards("Peasants", 2).has(peasants["new"]))

func verify_final_campaign() -> void:
	for city in CampaignState.STARTING_OWNERS:
		CampaignState.selected_city = city
		CampaignState.capture_selected_city()
	assert(CampaignState.is_final_battle())
	assert(CampaignState.enemy_city() == "City 7")
	CampaignState.selected_city = "Paris"
	CampaignState.capture_selected_city()
	assert(!CampaignState.is_final_battle())
	CampaignState.reset()

func verify_options() -> void:
	var peasants: Dictionary = reward.offers["Peasants"]
	var nobility: Dictionary = reward.offers["Nobility"]
	assert(peasants["old"].is_empty())
	assert(RewardRules.get_group_cards("Peasants", 1).has(peasants["new"]))
	assert(nobility["old"].is_empty())
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
	assert(CampaignState.player_deck.count(offer["old"]) == (old_count - 1 if !offer["old"].is_empty() else old_count))
	assert(CampaignState.player_deck.has(offer["new"]))
	assert(CampaignState.loyalty["Peasants"] == -1)
	assert(CampaignState.loyalty["Nobility"] == 1)
	assert(CampaignState.city_owner["Rouen"] == CampaignState.Faction.FRANKS)
	assert(current_scene is CampaignMap)
