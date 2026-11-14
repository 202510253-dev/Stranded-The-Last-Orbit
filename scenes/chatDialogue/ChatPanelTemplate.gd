extends Node2D

# Reusable dialogue panel scene
const CHAT_PANEL_SCENE := preload(
    "res://scenes/chatDialogue/chatPanel.tscn"
)

# Stores the runtime-created dialogue panel
var chat_panel: Control

# Portrait used by this character
var guide_portrait: Texture2D = preload(
    "res://assets/splashart/jinSplashArt.png"
)

func _ready() -> void:
    # Creates the CanvasLayer and ChatPanel
    create_chat_panel()

    # Starts the dialogue sequence
    await show_dialogue()


func create_chat_panel() -> void:
    # CanvasLayer keeps the dialogue fixed to the screen
    var canvas_layer := CanvasLayer.new()
    canvas_layer.name = "DialogueUI"
    canvas_layer.layer = 10
    add_child(canvas_layer)

    # Creates an instance of chatPanel.tscn
    chat_panel = CHAT_PANEL_SCENE.instantiate()
    canvas_layer.add_child(chat_panel)


func show_dialogue() -> void:
    # First argument: character name
    # Second argument: dialogue text
    # Third argument: character portrait
    await show_line(
        "Jin",
        "Welcome to Sputnik 2!",
        guide_portrait
    )

    await show_line(
        "Jin",
        "Come! It is time to design our shuttle.",
        guide_portrait
    )


func show_line(
    speaker_name: String, # Name displayed above the dialogue
    dialogue_text: String, # Text displayed in the dialogue box
    portrait: Texture2D # Portrait displayed beside the text
) -> void:
    # Sends the name, text, and portrait to the ChatPanel
    chat_panel.show_dialogue(
        speaker_name,
        dialogue_text,
        portrait
    )

    # Waits until the player clicks or presses interact
    await chat_panel.dialogue_finished