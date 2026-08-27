class_name CampaignMap extends Node2D

const SHIELD := preload("res://Textures/Shield.png")
@onready var title: Label = $CanvasLayer/KingdomLoyalty/PanelContent/TitleBackground/MarginContainer/Title
@onready var first_icon: TextureRect = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/Icon
@onready var second_icon: TextureRect = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/Icon
@onready var first_name: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/Peasants
@onready var second_name: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/Nobility
@onready var first_status: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/PeasantsStatus
@onready var second_status: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/NobilityStatus
@onready var tooltip: PanelContainer = $CanvasLayer/Tooltip
@onready var tooltip_title: Label = $CanvasLayer/Tooltip/MarginContainer/Content/Title
@onready var tooltip_changes := [$CanvasLayer/Tooltip/MarginContainer/Content/English, $CanvasLayer/Tooltip/MarginContainer/Content/HRE]
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var roads := {}
var input_disabled := false

func _ready() -> void:
    setup_roads()
    setup_cities()
    update_header()

func setup_roads() -> void:
    setup_road($MapElements/Roads/Road, CampaignState.Faction.FRANKS)
    setup_road($MapElements/Roads/EnglandRoad, CampaignState.Faction.ENGLISH)
    setup_road($MapElements/Roads/HRERoad, CampaignState.Faction.HRE)
    for index in 4:
        add_road(CampaignState.act_1_city_id(index + 1), CampaignState.act_1_city_id(index + 2))
        add_road(CampaignState.act_1_city_id(index + 2), CampaignState.act_1_city_id(index + 1))

func setup_road(road: Line2D, faction: CampaignState.Faction) -> void:
    var cities: Array[CampaignCity] = []
    road.clear_points()
    road.visible = faction == CampaignState.Faction.FRANKS || CampaignState.is_act_2()
    for child in $MapElements/Cities.get_children():
        var city := child as CampaignCity
        if city.faction == faction:
            cities.append(city)
    if faction != CampaignState.Faction.FRANKS:
        cities.sort_custom(func(first: CampaignCity, second: CampaignCity) -> bool: return first.route_index < second.route_index)
    for city in cities:
        road.add_point(city.position)

func add_road(source: String, target: String) -> void:
    if !roads.has(source):
        roads[source] = []
    roads[source].append(target)

func setup_cities() -> void:
    for child in $MapElements/Cities.get_children():
        var city := child as CampaignCity
        city.visible = city.faction == CampaignState.Faction.FRANKS || CampaignState.is_act_2()
        city.apply_owner(CampaignState.map_owner(city.city_id, city.faction, city.route_index))
        city.set_attackable(is_attackable(city))
        city.clicked.connect(_on_city_clicked)
        city.hovered.connect(_on_city_hovered)
        city.unhovered.connect(hide_tooltip)

func refresh_cities() -> void:
    for child in $MapElements/Cities.get_children():
        var city := child as CampaignCity
        city.apply_owner(CampaignState.map_owner(city.city_id, city.faction, city.route_index))
        city.set_attackable(is_attackable(city))

func is_attackable(city: CampaignCity) -> bool:
    var city_id := CampaignState.map_city_id(city.city_id)
    if CampaignState.is_act_2():
        if city_id == "Act 2 Boss":
            return !CampaignState.act_2_boss_defeated
        return CampaignState.can_declare_war(city.faction, city.route_index) || CampaignState.can_attack_act_2(city.faction, city.route_index)
    if city_id == CampaignState.act_1_city_id(1) || city_id == "Act 1 Boss":
        return CampaignState.city_owner.get(CampaignState.act_1_city_id(1), CampaignState.Faction.FRANKS) == CampaignState.Faction.REBELS
    if !CampaignState.city_owner.has(city_id) || CampaignState.city_owner[city_id] != CampaignState.Faction.REBELS:
        return false
    return roads.get(city_id, []).any(func(neighbor: String) -> bool: return CampaignState.city_owner[neighbor] == CampaignState.Faction.FRANKS)

func update_header() -> void:
    if CampaignState.is_act_2():
        title.text = "FOREIGN RELATIONS"
        set_foreign_label(first_name, first_icon, first_status, CampaignState.Faction.ENGLISH)
        set_foreign_label(second_name, second_icon, second_status, CampaignState.Faction.HRE)
        return
    set_loyalty_label(first_status, CampaignState.loyalty["Peasants"])
    set_loyalty_label(second_status, CampaignState.loyalty["Nobility"])

func set_foreign_label(name_label: Label, icon: TextureRect, status: Label, faction: CampaignState.Faction) -> void:
    name_label.text = CampaignState.faction_name(faction)
    icon.texture = SHIELD
    icon.modulate = CampaignState.faction_color(faction)
    set_loyalty_label(status, CampaignState.foreign_loyalty[faction])

func set_loyalty_label(label: Label, loyalty_value: int) -> void:
    label.text = RelationData.loyalty_name(loyalty_value)
    label.add_theme_color_override("font_color", RelationData.color(loyalty_value))

func _on_city_hovered(city: CampaignCity) -> void:
    if !CampaignState.can_declare_war(city.faction, city.route_index):
        return
    tooltip.position = city.global_position + Vector2(30, -55)
    tooltip_title.text = "Declare war on %s" % CampaignState.faction_name(city.faction)
    set_tooltip_change(0, city.faction, CampaignState.Relation.WAR)
    set_tooltip_change(1, CampaignState.other_foreign_faction(city.faction), CampaignState.Relation.MILITARY_ALLIANCE)
    tooltip.show()

func set_tooltip_change(index: int, faction: CampaignState.Faction, target: int) -> void:
    var change := tooltip_changes[index] as HBoxContainer
    var icon := change.get_node("Group/Icon") as TextureRect
    var name := change.get_node("Group/Name") as Label
    icon.texture = SHIELD
    icon.modulate = CampaignState.faction_color(faction)
    name.text = CampaignState.faction_name(faction)
    set_loyalty_label(change.get_node("Change/Current"), CampaignState.foreign_loyalty[faction])
    set_loyalty_label(change.get_node("Change/Target"), target)

func hide_tooltip(_city: CampaignCity = null) -> void:
    tooltip.hide()

func _on_city_clicked(city: CampaignCity) -> void:
    if input_disabled || !city.attackable:
        return
    if CampaignState.can_declare_war(city.faction, city.route_index):
        CampaignState.declare_war(city.faction)
    else:
        CampaignState.selected_city = CampaignState.map_city_id(city.city_id)
    input_disabled = true
    confirm_sound.play()
    await fade.fade_out()
    get_tree().change_scene_to_file("res://Scenes/Battlefield/Battlefield.tscn")
