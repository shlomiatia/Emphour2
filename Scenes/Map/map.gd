class_name CampaignMap extends Node2D

@onready var peasants_status: Label = $CanvasLayer/KingdomLoyalty/PeasantsStatus
@onready var nobility_status: Label = $CanvasLayer/KingdomLoyalty/NobilityStatus
@onready var fade: Fade = $CanvasLayer/Fade
@onready var confirm_sound: AudioStreamPlayer = $ConfirmSound

var roads := {}
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
		city.clicked.connect(_on_city_clicked)
		city.apply_owner(CampaignState.city_owner[city.city_name])
		city.set_attackable(is_attackable(city.city_name))

func is_attackable(city_name: String) -> bool:
	if CampaignState.city_owner[city_name] != CampaignState.Faction.REBELS:
		return false
	if city_name == "Paris":
		return true
	for neighbor in roads.get(city_name, []):
		if CampaignState.city_owner[neighbor] == CampaignState.Faction.FRANKS:
			return true
	return false

func update_header() -> void:
	set_loyalty_label(peasants_status, CampaignState.public_loyalty["Peasants"])
	set_loyalty_label(nobility_status, CampaignState.public_loyalty["Nobility"])

func set_loyalty_label(label: Label, loyalty_value: int) -> void:
	label.text = RelationData.loyalty_name(loyalty_value)
	label.add_theme_color_override("font_color", RelationData.color(loyalty_value))

func _on_city_clicked(city: CampaignCity) -> void:
	if input_disabled || !city.attackable:
		return
	input_disabled = true
	CampaignState.selected_city = city.city_name
	confirm_sound.play()
	await fade.fade_out()
	get_tree().change_scene_to_file("res://Scenes/Battle/Battle.tscn")
