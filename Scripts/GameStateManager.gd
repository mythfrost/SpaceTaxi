extends Node
class_name GameStateManager

var current_state: GameState = null

func _ready() -> void:
	var main_scene = get_tree().get_current_scene()
	_GameStateManager.change_state(PlayingState.new(main_scene))

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
	var owner: Node
	var quest_active: bool = false
	var quest_target: Node2D = null

	func _init(o: Node) -> void:
		owner = o

	func enter() -> void:
		owner.get_tree().paused = false

	func handle_input(event) -> void:
		var ship = owner.get_node("Spaceship") as Spaceship
		if event is InputEventKey and event.pressed:
			if event.is_action_pressed("ui_accept"):
				if not ship.is_launched:
					ship.launch()
					owner.get_node("CanvasLayer/Button").hide()
				elif ship.is_orbiting:
					ship.break_orbit()
			elif event.is_action_pressed("ui_cancel"):
				_GameStateManager.change_state(PausedState.new(owner))
			elif event.is_action_pressed("obtain_quest") and ship.is_orbiting:
				# pick and show a random quest
				var quest_list: Array = ship.quests
				var chosen: String = quest_list[randi() % quest_list.size()]
				owner.get_node("CanvasLayer2/QuestLabel").text = chosen

				# point arrow at random planet
				var planets: Array = owner.get_tree().get_nodes_in_group("Planets")
				quest_target = planets[randi() % planets.size()] as Node2D
				var arrow = owner.get_node("CanvasLayer/Arrow")
				arrow.show()
				quest_active = true

	func update(delta: float) -> void:
		# update arrow to follow moving planet
		if quest_active and quest_target:
			var arrow = owner.get_node("CanvasLayer/Arrow")
			var cam = owner.get_node("WorldCam") as Camera2D
			if cam:
				arrow.rotation = (quest_target.global_position - cam.global_position).angle()

# --- Paused State ---
class PausedState extends GameState:
	var owner: Node

	func _init(o: Node) -> void:
		owner = o

	func enter() -> void:
		owner.get_tree().paused = true
		owner.get_node("CanvasLayer/PauseMenu").visible = true

	func exit() -> void:
		owner.get_tree().paused = false
		owner.get_node("CanvasLayer/PauseMenu").visible = false

	func handle_input(event) -> void:
		if Input.is_action_just_pressed("ui_cancel"):
			_GameStateManager.change_state(PlayingState.new(owner))

	func update(delta: float) -> void:
		pass
