extends CanvasLayer
signal completed

@onready var loading_bar: AnimatedSprite2D = $Content/LoadingScreen/LoadingBar
@onready var loading_screen: Control = $Content/LoadingScreen
@onready var stage_1: Control = $Content/Stage1
@onready var stage_2: Control = $Content/Stage2
@onready var stage_3: Control = $Content/Stage3
@onready var stage_4: Control = $Content/Stage4
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

var selected_material: String = ""
var selected_weight: float = 0.0
var stored_material: String = ""
var stored_weight: float = 0.0
var selected_oxygen: int = 0
var stored_oxygen: int = 0
var selected_fuel: int = 0
var stored_fuel: int = 0

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
	loading_bar.play("loading")

func _on_loading_finished() -> void:
	if loading_bar.animation == "loading":
		await get_tree().create_timer(1.0).timeout
		loading_screen.hide()
		stage_1.show()
		material_label.show()
		weight_label.show()
		next_button.show()

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
	elif stage_2.visible:
		if selected_oxygen == 0:
			return
		stored_oxygen = selected_oxygen
		stage_2.hide()
		stage_3.show()
	elif stage_3.visible:
		if selected_fuel == 0:
			return
		stored_fuel = selected_fuel
		stage_3.hide()
		stage_4.show()
		next_button.hide()
