class_name RewardScreen extends Node2D

@onready var peasants: RewardOption = $CanvasLayer/Peasants
@onready var nobility: RewardOption = $CanvasLayer/Nobility
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var offers := {}
var input_disabled := false
var final_reward := false

func _ready() -> void:
    final_reward = CampaignState.is_final_battle()
    create_options()

func create_options() -> void:
    if final_reward:
        create_final_options()
        return
    if CampaignState.is_act_2():
        create_act_2_options()
        return
    for group in ["Peasants", "Nobility"]:
        offers[group] = RewardRules.create_offer(group, CampaignState.loyalty[group], CampaignState.player_deck)
    peasants.setup(offers["Peasants"])
    nobility.setup(offers["Nobility"])
    peasants.setup_loyalty("Peasants", true)
    nobility.setup_loyalty("Nobility", true)

func create_act_2_options() -> void:
    setup_act_2_option(peasants, CampaignState.Faction.ENGLISH)
    setup_act_2_option(nobility, CampaignState.Faction.HRE)

func setup_act_2_option(option: RewardOption, faction: CampaignState.Faction) -> void:
    option.group_name = CampaignState.faction_name(faction)
    option.choice_id = ""
    offers[option.group_name] = Act2RewardRules.create_offer(faction, CampaignState.city_number(CampaignState.selected_city) - 1, CampaignState.player_deck)
    option.setup(offers[option.group_name])
    option.setup_loyalty("", false)

func create_final_options() -> void:
    var group := CampaignState.loyal_group()
    setup_boss_option(peasants, group, "boss_1", 1)
    setup_boss_option(nobility, group, "boss_2", 2)
    peasants.setup_loyalty("Peasants", false)
    nobility.setup_loyalty("Nobility", false)

func setup_boss_option(option: RewardOption, group: String, key: String, index: int) -> void:
    option.group_name = group
    option.choice_id = key
    offers[key] = RewardRules.create_boss_offer(group, index, CampaignState.player_deck)
    option.setup(offers[key])

func _on_option_chosen(group: String) -> void:
    if input_disabled:
        return
    input_disabled = true
    RewardRules.apply_offer(offers[group], CampaignState.player_deck)
    if !final_reward && !CampaignState.is_act_2():
        apply_loyalty(group)
    CampaignState.capture_selected_city()
    confirm_sound.play()
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Scenes/Map/Map.tscn")

func apply_loyalty(group: String) -> void:
    var other := "Nobility" if group == "Peasants" else "Peasants"
    CampaignState.change_loyalty(group, 1)
    CampaignState.change_loyalty(other, -1)
