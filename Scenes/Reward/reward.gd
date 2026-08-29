class_name RewardScreen extends Node2D

const TUTORIAL_ID := "reward_loyalty"
const ACT_2_TUTORIAL_ID := "act_2_reward"
const TUTORIAL_TEXTS := [
    "tutorial.reward.won",
    "tutorial.reward.offers",
    "tutorial.reward.loyalty",
    "tutorial.reward.better",
    "tutorial.reward.other"
]
const ACT_2_TUTORIAL_TEXTS := [
    "tutorial.reward.levies",
    "tutorial.reward.allies",
    "tutorial.reward.choice"
]

@onready var peasants: RewardOption = $CanvasLayer/Peasants
@onready var nobility: RewardOption = $CanvasLayer/Nobility
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound
@onready var tutorial: TutorialMessage = $TutorialMessage

var offers := {}
var input_disabled := false
var final_reward := false

func _ready() -> void:
    final_reward = CampaignState.is_final_battle()
    create_options()
    show_tutorial()

func show_tutorial() -> void:
    if final_reward:
        return
    if CampaignState.is_act_2():
        if CampaignState.start_tutorial(ACT_2_TUTORIAL_ID):
            tutorial.show_messages(act_2_tutorial_texts())
        return
    if CampaignState.start_tutorial(TUTORIAL_ID):
        tutorial.show_messages(TUTORIAL_TEXTS.map(func(text: String) -> String: return tr(text)))

func act_2_tutorial_texts() -> Array:
    return [tr(ACT_2_TUTORIAL_TEXTS[0]) % CampaignState.faction_dialogue_name(CampaignState.faction_at_war()), tr(ACT_2_TUTORIAL_TEXTS[1]), tr(ACT_2_TUTORIAL_TEXTS[2])]

func create_options() -> void:
    if final_reward:
        create_final_options()
        return
    if CampaignState.is_act_2():
        create_act_2_options()
        return
    for group in ["Peasants", "Nobility"]:
        offers[group] = RewardRules.create_offer(group, CampaignState.city_number(CampaignState.selected_city), CampaignState.player_deck)
    peasants.setup(offers["Peasants"])
    nobility.setup(offers["Nobility"])
    peasants.setup_loyalty("Peasants", true)
    nobility.setup_loyalty("Nobility", true)

func create_act_2_options() -> void:
    setup_act_2_option(peasants, CampaignState.Faction.ENGLISH)
    setup_act_2_option(nobility, CampaignState.Faction.HRE)
    peasants.setup_foreign_loyalty()
    nobility.setup_foreign_loyalty()

func setup_act_2_option(option: RewardOption, faction: CampaignState.Faction) -> void:
    option.group_name = CampaignState.faction_name(faction)
    option.choice_id = ""
    offers[option.group_name] = Act2RewardRules.create_offer(faction, CampaignState.city_number(CampaignState.selected_city), CampaignState.player_deck)
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
    get_tree().change_scene_to_file("res://Scenes/Intro/Intro.tscn" if final_reward else "res://Scenes/Map/Map.tscn")

func apply_loyalty(group: String) -> void:
    var other := "Nobility" if group == "Peasants" else "Peasants"
    CampaignState.change_loyalty(group, 1)
    CampaignState.change_loyalty(other, -1)
