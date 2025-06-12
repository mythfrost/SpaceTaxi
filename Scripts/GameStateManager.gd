# GameStateManager.gd
extends Node
class_name GameStateManager

var current_state: GameState = null

func _ready() -> void:
	var main_scene := get_tree().current_scene
	change_state( PlayingState.new(main_scene) )

func change_state(new_state: GameState) -> void:
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()

func _input(event) -> void:
	if current_state:
		current_state.handle_input(event)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)


# Base interface
class GameState:
	func enter(): pass
	func exit(): pass
	func handle_input(event): pass
	func update(delta): pass


# --- Playing State ---
class PlayingState extends GameState:
	var owner

	func _init(o):
		owner = o

	func enter() -> void:
		owner.get_tree().paused = false
 
	func handle_input(event) -> void:
		var ship: Spaceship = owner.get_node("Spaceship") as Spaceship

		# — SPACE: launch or break orbit
		if event is InputEventKey and Input.is_action_pressed("ui_accept"):
			if not ship.is_launched:
				ship.launch()
				# hide the UI button too, in case they pressed Space
				owner.get_node("CanvasLayer/Button").hide()
			elif ship.is_orbiting and not ship.is_landed:
				ship.break_orbit()

		# — ESC: pause
		if event is InputEventKey and Input.is_action_pressed("ui_cancel"):
			_GameStateManager.change_state( PausedState.new(owner) )

		# — R: land/unland
		if event is InputEventKey and Input.is_action_pressed("land"):
			if ship.is_orbiting and not ship.is_landed:
				ship.land()
				_GameStateManager.change_state( LandedState.new(owner) )

	func update(delta: float) -> void:
		var ship: Spaceship = owner.get_node("Spaceship") as Spaceship
		ship._physics_process(delta)


# --- Paused State ---
class PausedState extends GameState:
	var owner

	func _init(o):
		owner = o

	func enter() -> void:
		owner.get_tree().paused = true
		owner.get_node("CanvasLayer/PauseMenu").visible = true

	func exit() -> void:
		owner.get_tree().paused = false
		owner.get_node("CanvasLayer/PauseMenu").visible = false

	func handle_input(event) -> void:
		if event is InputEventKey and event.is_action_pressed("ui_cancel"):
			_GameStateManager.change_state(PlayingState.new(owner))

	func update(delta: float) -> void:
		pass


# --- Landed State ---
class LandedState extends GameState:
	var owner

	func _init(o):
		owner = o

	func enter() -> void:
		owner.get_node("CanvasLayer2/QuestLabel").visible = true

	func handle_input(event) -> void:
		if event is InputEventKey and event.is_action_pressed("land"):
			var ship := owner.get_node("Spaceship") as Spaceship
			ship.unland()
			owner.get_node("CanvasLayer2/QuestLabel").visible = false
			_GameStateManager.change_state(PlayingState.new(owner))

	func update(delta: float) -> void:
		pass
