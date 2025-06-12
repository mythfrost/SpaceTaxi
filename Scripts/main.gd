# Main.gd
extends Node2D

@onready var spaceship           = $Spaceship
@onready var fuel_bar            = $CanvasLayer/FuelBar
@onready var secondary_fuel_bar  = $CanvasLayer/SecondaryFuelBar
@onready var launch_button       = $CanvasLayer/Button
@onready var arrow               = $CanvasLayer/Arrow
@onready var quest_label         = $CanvasLayer2/QuestLabel

var zoom1 := Vector2(1, 1)
var zoom2 := Vector2(0.5, 0.5)
var using_zoom1 := true
var _zoom_pressed_last_frame := false

func _ready() -> void:
	# start FSM on this scene
	_GameStateManager.change_state(GameStateManager.PlayingState.new(self))
	# hook UI
	launch_button.pressed.connect(_on_LaunchButton_pressed)
	secondary_fuel_bar.max_value = spaceship.max_turn_fuel

func _on_LaunchButton_pressed() -> void:
	spaceship.launch()
	launch_button.hide()

func _input(event) -> void:
	# forward input to FSM
	_GameStateManager._input(event)

func _process(delta: float) -> void:

	# update UI
	if spaceship.is_launched:
		fuel_bar.value           = spaceship.current_fuel
		secondary_fuel_bar.value = spaceship.turn_fuel

	_GameStateManager._process(delta)
