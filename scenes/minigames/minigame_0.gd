extends CanvasLayer
signal completed

const GUIDE_PORTRAIT := preload("res://assets/splashart/jinSplashArt.png")
const CHAT_PANEL_SCENE := preload("res://scenes/chatDialogue/chatPanel.tscn")
const OXYGEN_LITERS := 1200.0
const LITERS_PER_GALLON := 3.785
const OXYGEN_DENSITY_LBS_PER_GALLON := 0.0119
const FOOD_DENSITY_LBS_PER_GALLON := 8.34
const WEIGHT_CAP_LBS := 1121.0 # weight of Sputnik 2
const EQUIPMENT_WEIGHT_LBS := 823.6 # instruments, life support, transmitters, cabin

@onready var loading_bar: AnimatedSprite2D = $Content/LoadingScreen/LoadingBar
@onready var loading_screen: Control = $Content/LoadingScreen
@onready var stage_1: Control = $Content/Stage1
@onready var stage_2: Control = $Content/Stage2
@onready var stage_3: Control = $Content/Stage3
@onready var stage_4: Control = $Content/Summary
@onready var bottom_1: Control = $Content/BottomContainer
@onready var material_label: Label = $Content/BottomContainer/MaterialLabel
@onready var weight_label: Label = $Content/BottomContainer/WeightLabel
@onready var button_1: TextureButton = $Content/Stage1/Container/Button1
@onready var button_2: TextureButton = $Content/Stage1/Container/Button2
@onready var button_3: TextureButton = $Content/Stage1/Container/Button3
@onready var oxygen_button_1: TextureButton = $Content/Stage2/Container/Button1
@onready var oxygen_button_2: TextureButton = $Content/Stage2/Container/Button2
@onready var oxygen_button_3: TextureButton = $Content/Stage2/Container/Button3
@onready var fuel_button_1: TextureButton = $Content/Stage3/Container/Button1
@onready var fuel_button_2: TextureButton = $Content/Stage3/Container/Button2
@onready var fuel_button_3: TextureButton = $Content/Stage3/Container/Button3
@onready var next_button: TextureButton = $Content/BottomContainer/NextButton
@onready var retry_button: TextureButton = $HBoxContainer/No
@onready var confirm_button: TextureButton = $HBoxContainer/Yes
@onready var summary_actions: Control = $HBoxContainer
@onready var confirmation_prompt: Control = $VBoxContainer

var selected_material: String = ""
var selected_weight: float = 0.0
var stored_material: String = ""
var stored_weight: float = 0.0
var selected_oxygen: float = 0
var stored_oxygen: float = 0
var selected_fuel: float = 0
var stored_fuel: float = 0
var passenger_weight: float = 5 # Weight ni laika
var chat_panel: Control
var _confirming := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	loading_screen.show()
	stage_1.hide()
	stage_2.hide()
	stage_3.hide()
	stage_4.hide()
	summary_actions.hide()
	confirmation_prompt.hide()
	bottom_1.show()
	material_label.hide()
	weight_label.hide()
	next_button.hide()

	chat_panel = _get_chat_panel()
	if chat_panel == null:
		return
	if not chat_panel.is_node_ready():
		await chat_panel.ready

	loading_bar.animation_finished.connect(_on_loading_finished)
	button_1.pressed.connect(_on_button_1_pressed)
	button_2.pressed.connect(_on_button_2_pressed)
	button_3.pressed.connect(_on_button_3_pressed)
	oxygen_button_1.pressed.connect(_on_oxygen_button_1_pressed)
	oxygen_button_2.pressed.connect(_on_oxygen_button_2_pressed)
	oxygen_button_3.pressed.connect(_on_oxygen_button_3_pressed)
	fuel_button_1.pressed.connect(_on_fuel_button_1_pressed)
	fuel_button_2.pressed.connect(_on_fuel_button_2_pressed)
	fuel_button_3.pressed.connect(_on_fuel_button_3_pressed)
	next_button.pressed.connect(_on_next_button_pressed)
	retry_button.pressed.connect(_on_retry_button_pressed)
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	loading_bar.play("loading")

func _get_chat_panel() -> Control:
	var shared_panel := get_tree().root.find_child("ChatPanel", true, false) as Control
	if shared_panel != null and _has_chat_content(shared_panel):
		return shared_panel

	var fallback_layer := CanvasLayer.new()
	fallback_layer.layer = 100
	get_tree().root.add_child(fallback_layer)

	var fallback_panel := CHAT_PANEL_SCENE.instantiate() as Control
	if fallback_panel == null:
		push_error("Chat panel scene does not contain a Control root.")
		fallback_layer.queue_free()
		return null

	fallback_layer.add_child(fallback_panel)
	return fallback_panel

func _has_chat_content(panel: Control) -> bool:
	return (
		panel.get_node_or_null("MarginContainer/HBoxContainer/Name") != null
		and panel.get_node_or_null("MarginContainer/HBoxContainer/Content/Text") != null
	)

func _fixed_weight() -> float:
	return EQUIPMENT_WEIGHT_LBS + passenger_weight

func _total_weight() -> float:
	return (
		stored_weight
		+ stored_oxygen * OXYGEN_DENSITY_LBS_PER_GALLON
		+ stored_fuel * FOOD_DENSITY_LBS_PER_GALLON
		+ _fixed_weight()
	)

func _on_loading_finished() -> void:
	if loading_bar.animation == "loading":
		await get_tree().create_timer(1.0).timeout
		loading_screen.hide()
		stage_1.show()
		material_label.show()
		weight_label.show()
		next_button.show()
		await show_line(
			"Jin",
			"The instruments, life support, and Laika already weigh "
			+ String.num(_fixed_weight(), 1)
			+ " lb. Everything you add must keep the total under "
			+ String.num(WEIGHT_CAP_LBS, 0) + " lb.",
		)
		await show_line(
			"Jin",
			"First, every weight you add, the rocket must carry. Start with the shell.",
		)


func _on_button_1_pressed() -> void: #select shuttle material in kilograms muna
	_select_material("Steel", 814.0) # option 1 (choosing the material)

func _on_button_2_pressed() -> void:
	_select_material("Aluminum", 280.0) #option 2

func _on_button_3_pressed() -> void:
	_select_material("Titanium", 467.0) # option 3

func _select_material(material: String, weight: float) -> void:
	# store ung selections
	# para i compile later kung
	# kung tama ung total combined weight ng compartmentsA
	selected_material = material
	selected_weight = weight
	material_label.text = "Material: " + selected_material
	weight_label.text = "Weight: " + String.num(selected_weight, 2) + " lbs"

func _on_oxygen_button_1_pressed() -> void:
	_select_oxygen((OXYGEN_LITERS * 2.0) / LITERS_PER_GALLON)

func _on_oxygen_button_2_pressed() -> void:
	_select_oxygen(OXYGEN_LITERS / LITERS_PER_GALLON)

func _on_oxygen_button_3_pressed() -> void:
	_select_oxygen((OXYGEN_LITERS * 10.0) / LITERS_PER_GALLON)

func _select_oxygen(capacity: float) -> void:
	selected_oxygen = capacity
	material_label.text = "Oxygen: " + String.num(selected_oxygen, 2) + " Gallons"
	weight_label.text = "Weight: " + String.num(
		selected_oxygen * OXYGEN_DENSITY_LBS_PER_GALLON,
		2
	) + " lbs"

func _on_fuel_button_1_pressed() -> void:
	_select_fuel(1.6) #food for 7 days in gallons

func _on_fuel_button_2_pressed() -> void:
	_select_fuel(0.8)

func _on_fuel_button_3_pressed() -> void:
	_select_fuel(7.9)

func _select_fuel(capacity: float) -> void:
	selected_fuel = capacity
	material_label.text = "Food: " + String.num(selected_fuel, 2) + " Gallons"
	weight_label.text = "Weight: " + String.num(
		selected_fuel * FOOD_DENSITY_LBS_PER_GALLON,
		2
	) + " lbs"

func _on_next_button_pressed() -> void:
	if stage_1.visible:
		if selected_material.is_empty():
			return
		stored_material = selected_material
		stored_weight = selected_weight
		stage_1.hide()
		stage_2.show()
		await show_line(
			"Jin",
			"Now choose the oxygen capacity. A larger tank supports more oxygen, but takes more space.",
		)
	elif stage_2.visible:
		if selected_oxygen == 0:
			return
		stored_oxygen = selected_oxygen
		stage_2.hide()
		stage_3.show()
		await show_line(
			"Jin",
			"Finally, choose the Food capacity for our BELOVED Laika.",
		)
	elif stage_3.visible:
		if selected_fuel == 0:
			return
		stored_fuel = selected_fuel
		material_label.text = (
			"Material: " + stored_material
			+ " | Oxygen: " + String.num(stored_oxygen, 2) + " Gallons"
		)
		weight_label.text = "Food: " + String.num(stored_fuel, 2) + " Gallons"
		stage_3.hide()
		stage_3.visible = false
		stage_4.show()
		stage_4.visible = true
		bottom_1.hide()
		confirmation_prompt.show()
		summary_actions.show()
		# bottom_1.visible = false
		next_button.hide()

func _on_retry_button_pressed() -> void:
	selected_material = ""
	selected_weight = 0.0
	stored_material = ""
	stored_weight = 0.0
	selected_oxygen = 0
	stored_oxygen = 0
	selected_fuel = 0
	stored_fuel = 0
	_confirming = false

	for button in [
		button_1, button_2, button_3,
		oxygen_button_1, oxygen_button_2, oxygen_button_3,
		fuel_button_1, fuel_button_2, fuel_button_3
	]:
		button.set_pressed(false)

	material_label.text = "Material: ---"
	weight_label.text = "Weight: ---"
	stage_4.hide()
	bottom_1.show()
	confirmation_prompt.hide()
	summary_actions.hide()
	stage_2.hide()
	stage_3.hide()
	stage_1.show()
	next_button.show()

func _on_confirm_button_pressed() -> void:
	if _confirming:
		return

	_confirming = true

	# Passing is decided by total weight. Only the all-B combination
	# (Aluminum, 1x oxygen, 0.8 gal food) fits under the cap.
	if _total_weight() <= WEIGHT_CAP_LBS:
		completed.emit()
		return

	# Hint: list the choices that are heavier than the B option.
	var wrong_options := PackedStringArray()
	if stored_material != "Aluminum":
		wrong_options.append("the material (" + stored_material + ")")
	if not is_equal_approx(stored_oxygen, OXYGEN_LITERS / LITERS_PER_GALLON):
		wrong_options.append(
			"the oxygen capacity (" + String.num(stored_oxygen, 2) + " gallons)"
		)
	if not is_equal_approx(stored_fuel, 0.8):
		wrong_options.append(
			"the food capacity (" + String.num(stored_fuel, 2) + " gallons)"
		)

	await show_line(
		"Jin",
		"That doesnt seem to be right, try and cut off some weight from "
		+ ", ".join(wrong_options) + ".",
	)
	await show_line(
		"Jin",
		"The total weight should not exceed " + String.num(WEIGHT_CAP_LBS, 0) + " lb"
	)
	await show_line(
			"Jin",
			"The instruments, life support, and Laika already weigh "
			+ String.num(_fixed_weight(), 1)
			+ " lb. Everything you add must keep the total under "
			+ String.num(WEIGHT_CAP_LBS, 0) + " lb.",
		)
	_confirming = false

func show_line(speaker_name: String, dialogue_text: String) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text, GUIDE_PORTRAIT)
	await chat_panel.dialogue_finished
