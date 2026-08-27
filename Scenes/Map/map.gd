class_name CampaignMap extends Node2D

const SHIELD := preload("res://Textures/Shield.png")
@onready var title: Label = $CanvasLayer/KingdomLoyalty/PanelContent/TitleBackground/MarginContainer/Title
@onready var first_icon: TextureRect = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/Icon
@onready var second_icon: TextureRect = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/Icon
@onready var first_name: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/Peasants
@onready var second_name: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/Nobility
@onready var peasants_status: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/PeasantsContainer/PeasantsStatus
@onready var nobility_status: Label = $CanvasLayer/KingdomLoyalty/PanelContent/MarginContainer/ContentTitleContainer/NobilityContainer/NobilityStatus
@onready var tooltip: PanelContainer = $CanvasLayer/Tooltip
@onready var tooltip_title: Label = $CanvasLayer/Tooltip/MarginContainer/Content/Title
@onready var tooltip_changes := [$CanvasLayer/Tooltip/MarginContainer/Content/English, $CanvasLayer/Tooltip/MarginContainer/Content/Hre]
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var roads := {}
var input_disabled := false

func _ready() -> void:
	setup_roads()
	setup_cities()
	update_header()

func city_key(index: int) -> String:
	return "City %d" % index

func city_id(city: CampaignCity) -> String:
	return city.city_name if CampaignState.is_foreign_city(city.city_name) else city_key(city.get_index() + 1)

func setup_roads() -> void:
	var road := $MapElements/Roads/Road as Line2D
	$MapElements/Roads/EnglandRoad.visible = CampaignState.foreign_relations_active()
	$MapElements/Roads/HreRoad.visible = CampaignState.foreign_relations_active()
	for index in 6:
		road.add_point($MapElements/Cities.get_child(index).position)
	for index in 5:
		add_road(city_key(index + 1), city_key(index + 2))
		add_road(city_key(index + 2), city_key(index + 1))

func add_road(source: String, target: String) -> void:
	if !roads.has(source):
		roads[source] = []
	roads[source].append(target)

func setup_cities() -> void:
	for child in $MapElements/Cities.get_children():
		var city := child as CampaignCity
		var key := city_id(city)
		city.visible = !CampaignState.is_foreign_city(key) || CampaignState.foreign_relations_active()
		city.apply_owner(CampaignState.FOREIGN_CITIES.get(key, CampaignState.city_owner.get(key, CampaignState.Faction.REBELS)))
		city.set_attackable(is_attackable(key))
		city.clicked.connect(_on_city_clicked)
		city.hovered.connect(_on_city_hovered)
		city.unhovered.connect(hide_tooltip)

func refresh_cities() -> void:
	for city in $MapElements/Cities.get_children():
		city.set_attackable(is_attackable(city_id(city)))

func is_attackable(city_name: String) -> bool:
	if CampaignState.is_foreign_city(city_name):
		return CampaignState.foreign_relations_active() && CampaignState.war_faction == CampaignState.Faction.REBELS && CampaignState.DECLARATION_CITIES.has(city_name)
	if CampaignState.city_owner[city_name] != CampaignState.Faction.REBELS:
		return false
	if city_name == city_key(1):
		return true
	for neighbor in roads.get(city_name, []):
		if CampaignState.city_owner[neighbor] == CampaignState.Faction.FRANKS:
			return true
	return false

func update_header() -> void:
	if CampaignState.foreign_relations_active():
		set_foreign_header()
		return
	set_loyalty_label(peasants_status, CampaignState.loyalty["Peasants"])
	set_loyalty_label(nobility_status, CampaignState.loyalty["Nobility"])

func set_foreign_header() -> void:
	title.text = "FOREIGN RELATIONS"
	set_foreign_label(first_name, first_icon, peasants_status, CampaignState.Faction.ENGLISH)
	set_foreign_label(second_name, second_icon, nobility_status, CampaignState.Faction.HRE)

func set_foreign_label(name_label: Label, icon: TextureRect, status: Label, faction: CampaignState.Faction) -> void:
	name_label.text = CampaignState.faction_name(faction)
	icon.texture = SHIELD
	icon.modulate = CampaignState.faction_color(faction)
	set_loyalty_label(status, CampaignState.foreign_loyalty[faction])

func set_loyalty_label(label: Label, loyalty_value: int) -> void:
	label.text = RelationData.loyalty_name(loyalty_value)
	label.add_theme_color_override("font_color", RelationData.color(loyalty_value))

func _on_city_hovered(city: CampaignCity) -> void:
	if !CampaignState.DECLARATION_CITIES.has(city.city_name) || CampaignState.war_faction != CampaignState.Faction.REBELS:
		return
	var faction: CampaignState.Faction = CampaignState.DECLARATION_CITIES[city.city_name]
	var other := CampaignState.other_foreign_faction(faction)
	tooltip.position = city.global_position + Vector2(30, -55)
	tooltip_title.text = "Declare war on %s" % CampaignState.faction_name(faction)
	set_tooltip_change(0, faction, CampaignState.Relation.WAR)
	set_tooltip_change(1, other, CampaignState.Relation.MILITARY_ALLIANCE)
	tooltip.show()

func set_tooltip_change(index: int, faction: CampaignState.Faction, target: int) -> void:
	var change := tooltip_changes[index] as HBoxContainer
	var icon := change.get_node("Group/Icon") as TextureRect
	icon.texture = SHIELD
	icon.modulate = CampaignState.faction_color(faction)
	(change.get_node("Group/Name") as Label).text = CampaignState.faction_name(faction)
	set_loyalty_label(change.get_node("Change/Current"), CampaignState.foreign_loyalty[faction])
	set_loyalty_label(change.get_node("Change/Target"), target)

func hide_tooltip(_city: CampaignCity = null) -> void:
	tooltip.hide()

func _on_city_clicked(city: CampaignCity) -> void:
	if input_disabled || !city.attackable:
		return
	if CampaignState.DECLARATION_CITIES.has(city.city_name):
		CampaignState.declare_war(CampaignState.DECLARATION_CITIES[city.city_name])
		confirm_sound.play()
		refresh_cities()
		update_header()
		hide_tooltip()
		return
	input_disabled = true
	CampaignState.selected_city = city_id(city)
	confirm_sound.play()
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Battlefield/Battlefield.tscn")
