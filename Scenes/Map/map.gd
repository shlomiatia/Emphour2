class_name CampaignMap extends Node2D

@onready var england_status: Label = $CanvasLayer/ForeignRelations/EnglandStatus
@onready var empire_status: Label = $CanvasLayer/ForeignRelations/EmpireStatus
@onready var peasants_status: Label = $CanvasLayer/KingdomLoyalty/PeasantsStatus
@onready var nobility_status: Label = $CanvasLayer/KingdomLoyalty/NobilityStatus
@onready var tooltip: Panel = $CanvasLayer/Tooltip
@onready var tooltip_title: Label = $CanvasLayer/Tooltip/Title
@onready var england_current: Label = $CanvasLayer/Tooltip/Grid/EnglandCurrent
@onready var england_target: Label = $CanvasLayer/Tooltip/Grid/EnglandTarget
@onready var empire_current: Label = $CanvasLayer/Tooltip/Grid/EmpireCurrent
@onready var empire_target: Label = $CanvasLayer/Tooltip/Grid/EmpireTarget
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var roads := {}
var hovered_city: CampaignCity
var input_disabled := false

func _ready() -> void:
	setup_roads()
	setup_cities()
	update_header()

func setup_roads() -> void:
	for road in $MapElements/Roads.get_children():
		var cities := String(road.name).split("To")
		add_road(cities[0], cities[1])
		add_road(cities[1], cities[0])

func add_road(source: String, target: String) -> void:
	if !roads.has(source):
		roads[source] = []
	roads[source].append(target)

func setup_cities() -> void:
	for child in $MapElements/Cities.get_children():
		var city := child as CampaignCity
		city.hovered.connect(_on_city_hovered)
		city.unhovered.connect(_on_city_unhovered)
		city.clicked.connect(_on_city_clicked)
		city.apply_owner(CampaignState.city_owner[city.city_name])
		city.set_attackable(is_attackable(city.city_name))

func is_attackable(city_name: String) -> bool:
	if CampaignState.city_owner[city_name] != CampaignState.Faction.REBELS:
		return false
	for neighbor in roads.get(city_name, []):
		if CampaignState.city_owner[neighbor] == CampaignState.Faction.FRANKS:
			return true
	return false

func update_header() -> void:
	set_relation_label(england_status, CampaignState.relations[CampaignState.Faction.ENGLAND])
	set_relation_label(empire_status, CampaignState.relations[CampaignState.Faction.HOLY_ROMAN_EMPIRE])
	set_loyalty_label(peasants_status, CampaignState.loyalty["Peasants"])
	set_loyalty_label(nobility_status, CampaignState.loyalty["Nobility"])

func _on_city_hovered(city: CampaignCity) -> void:
	hovered_city = city
	update_tooltip(city)
	tooltip.position = get_tooltip_position(city.position)
	tooltip.show()

func update_tooltip(city: CampaignCity) -> void:
	var england_result := get_target_relation(city.front, CampaignState.Faction.ENGLAND)
	var empire_result := get_target_relation(city.front, CampaignState.Faction.HOLY_ROMAN_EMPIRE)
	tooltip_title.text = "Attack %s" % city.city_name
	set_relation_label(england_current, CampaignState.relations[CampaignState.Faction.ENGLAND], true)
	set_relation_label(empire_current, CampaignState.relations[CampaignState.Faction.HOLY_ROMAN_EMPIRE], true)
	set_relation_label(england_target, england_result, true)
	set_relation_label(empire_target, empire_result, true)

func get_target_relation(front: CampaignState.Faction, faction: CampaignState.Faction) -> int:
	return CampaignState.Relation.TRADE_EMBARGO if front == faction else CampaignState.Relation.TRADE_PACT

func set_relation_label(label: Label, relation: int, dark_neutral := false) -> void:
	label.text = RelationData.relation_name(relation)
	label.add_theme_color_override("font_color", RelationData.color(relation, dark_neutral))

func set_loyalty_label(label: Label, loyalty_value: int) -> void:
	label.text = RelationData.loyalty_name(loyalty_value)
	label.add_theme_color_override("font_color", RelationData.color(loyalty_value))

func get_tooltip_position(city_position: Vector2) -> Vector2:
	var position := city_position + Vector2(36, 24)
	position.x = clampf(position.x, 20.0, 1300.0)
	position.y = clampf(position.y, 155.0, 875.0)
	return position

func _on_city_unhovered(city: CampaignCity) -> void:
	if hovered_city == city:
		hovered_city = null
		tooltip.hide()

func _on_city_clicked(city: CampaignCity) -> void:
	if input_disabled || !city.attackable:
		return
	input_disabled = true
	CampaignState.selected_city = city.city_name
	confirm_sound.play()
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Game/Game.tscn")
