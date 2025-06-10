# Main.gd
extends Node2D

@onready var spaceship           = $Spaceship
@onready var fuel_bar            = $CanvasLayer/FuelBar
@onready var secondary_fuel_bar  = $CanvasLayer/SecondaryFuelBar
@onready var launch_button       = $CanvasLayer/Button
@onready var arrow               = $CanvasLayer/Arrow
@onready var quest_label         = $CanvasLayer2/QuestLabel

func _ready() -> void:
	# UI wiring stays here
	launch_button.pressed.connect(lambda: GameStateManager._input(InputEventKey.new().set_action("ui_accept")))
	secondary_fuel_bar.max_value = spaceship.max_turn_fuel

func _input(event) -> void:
	# forward all input to the state manager
	GameStateManager._input(event)

func _process(delta: float) -> void:
	# update fuel bars when flying
	if spaceship.is_launched:
		fuel_bar.value           = spaceship.current_fuel
		secondary_fuel_bar.value = spaceship.turn_fuel
	# update arrow pointing
	GameStateManager._process(delta)
