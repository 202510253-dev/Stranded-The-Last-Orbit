extends CanvasLayer
signal completed

const GUIDE_PORTRAIT := preload("res://assets/splashart/jinSplashArt.png")
const CHAT_PANEL_SCENE := preload("res://scenes/chatDialogue/chatPanel.tscn")

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
@onready var summary_controls: Control = $HBoxContainer
@onready var summary_prompt: Control = $VBoxContainer


var selected_material: String = ""
var selected_weight: float = 0.0
var stored_material: String = ""
var stored_weight: float = 0.0
var selected_oxygen: int = 0
var stored_oxygen: int = 0
var selected_fuel: int = 0
var stored_fuel: int = 0

var chat_panel: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	loading_screen.show()
	stage_1.hide()
	stage_2.hide()
	stage_3.hide()
	stage_4.hide()
	material_label.hide()
	weight_label.hide()
	next_button.hide()
	summary_controls.hide()
	summary_prompt.hide()

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
	$HBoxContainer/Yes.pressed.connect(_on_summary_yes_pressed)
	$HBoxContainer/No.pressed.connect(_on_summary_no_pressed)
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

func _on_loading_finished() -> void:
	if loading_bar.animation == "loading":
		await get_tree().create_timer(1.0).timeout
		loading_screen.hide()
		stage_1.show()
		bottom_1.show()
		material_label.show()
		weight_label.show()
		next_button.show()
		await show_line(
			"Jin",
			"First, choose the material for the shuttle. Consider its weight and strength.",
		)

func _on_button_1_pressed() -> void:
	_select_material("Steel", 10.0)

func _on_button_2_pressed() -> void:
	_select_material("Aluminum", 5.0)

func _on_button_3_pressed() -> void:
	_select_material("Titanium", 15.0)

func _select_material(material: String, weight: float) -> void:
	selected_material = material
	selected_weight = weight
	material_label.text = "Material: " + selected_material
	weight_label.text = "Weight: " + str(selected_weight) + " kg"

func _on_oxygen_button_1_pressed() -> void:
	_select_oxygen(50)

func _on_oxygen_button_2_pressed() -> void:
	_select_oxygen(100)

func _on_oxygen_button_3_pressed() -> void:
	_select_oxygen(150)

func _select_oxygen(capacity: int) -> void:
	selected_oxygen = capacity
	material_label.text = "Oxygen: " + str(selected_oxygen)
	weight_label.text = "Capacity: " + str(selected_oxygen) + " L"

func _on_fuel_button_1_pressed() -> void:
	_select_fuel(25)

func _on_fuel_button_2_pressed() -> void:
	_select_fuel(50)

func _on_fuel_button_3_pressed() -> void:
	_select_fuel(75)

func _select_fuel(capacity: int) -> void:
	selected_fuel = capacity
	material_label.text = "Fuel: " + str(selected_fuel)
	weight_label.text = "Capacity: " + str(selected_fuel) + " L"

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
			"Finally, choose the fuel capacity. More fuel gives the shuttle more range.",
		)
	elif stage_3.visible:
		if selected_fuel == 0:
			return
		stored_fuel = selected_fuel
		stage_3.hide()
		bottom_1.visible = false
		next_button.hide()
		await show_line(
			"Jin",
			"You selected "
			+ stored_material
			+ ", weighing "
			+ str(stored_weight)
			+ " kg in total. Do you confirm?",
		)
		stage_4.show()
		summary_controls.show()
		summary_prompt.show()

func _on_summary_no_pressed() -> void:
	selected_material = ""
	selected_weight = 0.0
	stored_material = ""
	stored_weight = 0.0
	selected_oxygen = 0
	stored_oxygen = 0
	selected_fuel = 0
	stored_fuel = 0

	for button in [
		button_1, button_2, button_3,
		oxygen_button_1, oxygen_button_2, oxygen_button_3,
		fuel_button_1, fuel_button_2, fuel_button_3
	]:
		button.set_pressed(false)

	material_label.text = "Material: ---"
	weight_label.text = "Weight: ---"
	stage_4.hide()
	summary_controls.hide()
	summary_prompt.hide()
	stage_2.hide()
	stage_3.hide()
	stage_1.show()
	bottom_1.show()
	next_button.show()

func _on_summary_yes_pressed() -> void:
	completed.emit()

func show_line(speaker_name: String, dialogue_text: String) -> void:
	chat_panel.show_dialogue(speaker_name, dialogue_text, GUIDE_PORTRAIT)
	await chat_panel.dialogue_finished
