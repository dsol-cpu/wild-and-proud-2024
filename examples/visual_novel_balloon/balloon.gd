extends CanvasLayer


@onready var background: TextureRect = $Background
@onready var balloon: Control = $Balloon
@onready var dialogue_label: DialogueLabel = $Balloon/Margin/DialogueLabel
@onready var responses_menu: VBoxContainer = $Responses
@onready var response_template: RichTextLabel = $ResponseTemplate
@onready var example_particles: CPUParticles2D = $RainParticles
@onready var audio_sfx: AudioStreamPlayer = $AudioSFX
@onready var audio_ambiance: AudioStreamPlayer = $ambiance
@onready var parallax_ref: ParallaxBackground = $ParallaxTest/ParallaxBackground

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## Hard lock input at times for reasons
var input_locked: bool = false

var portraits: Dictionary = {}


#I have no idea what I'm doing
signal finish_pats
signal timer_start
signal timer_stop

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		if not next_dialogue_line:
			queue_free()
			return

		is_waiting_for_input = false

		# Remove any previous responses
		for child in responses_menu.get_children():
			responses_menu.remove_child(child)
			child.queue_free()

		dialogue_line = next_dialogue_line

		# Dim all characters except the one talking
		for portrait in portraits:
			if portrait == dialogue_line.character.to_lower():
				portraits[portrait].modulate = Color.WHITE
			else:
				portraits[portrait].modulate = Color("757575")

		dialogue_label.modulate.a = 0
		dialogue_label.dialogue_line = dialogue_line

		# Show any responses we have
		responses_menu.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				# Duplicate the template so we can grab the fonts, sizing, etc
				var item: RichTextLabel = response_template.duplicate(0)
				item.name = "Response%d" % responses_menu.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				responses_menu.add_child(item)

		dialogue_label.modulate.a = 1
		dialogue_label.type_out()
		await dialogue_label.finished_typing

		# Wait for input
		if dialogue_line.responses.size() > 0:
			responses_menu.modulate.a = 1
			configure_menu()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line

func coco_pat_complete() -> void:
	print("somehow pat")

func _ready() -> void:
	response_template.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	
	#Okay so if input is locked...let it through and don't pre-handle
	if input_locked: return
	
	get_viewport().set_input_as_handled()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = extra_game_states + [self]
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	if input_locked: return
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


### Mutations


func set_background(background_name: String) -> void:
	background.texture = load("res://examples/visual_novel_balloon/backgrounds/%s.jpg" % background_name)

func set_custom_background(background_name: String) -> void:
	background.texture = load("res://assets/art/backgrounds/%s.png" % background_name)

func add_portrait(character: String, slot: int = 0) -> void:
	var slot_marker: Marker2D = get_node("Slot%d" % slot)

	if slot_marker.get_child_count() > 0: return

	# Instantiate the character
	#var portrait = load("res://examples/visual_novel_balloon/portraits/%s.tscn" % character).instantiate()
	var portrait = load("res://assets/characters/%s.tscn" % character).instantiate()
	slot_marker.add_child(portrait)

	portraits[character] = portrait

	# Character appears
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(portrait, "position:y", 0.0, 0.5).from(1000.0)
	await get_tree().create_timer(0.8).timeout


func call_portrait(character: String, method: String) -> void:
	portraits[character].call(method)

func set_portrait(character: String, portrait_title: String) -> void:
	portraits[character].call("set_portrait", portrait_title)

func setupCocoPats() -> void:
	portraits["coco"].setup_signal_link(self)

func start_particles() -> void:
	example_particles.emitting = true

func stop_particles() -> void:
	example_particles.emitting = false
	
func pause_for_minigame() -> void:
	print("Hi do something")
	input_locked = true
	
func unpause_from_minigame() -> void:
	print("Back to stuff")
	input_locked = false
	next(dialogue_line.next_id)

func stop_train() -> void:
	audio_ambiance.stop()
	parallax_ref.scroll_base_scale = Vector2(0, 0)
	parallax_ref.call("train_stopped")
	

func remove_portrait(character: String) -> void:
	var portrait = portraits[character]

	# Character leaves
	var tween: Tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(portrait, "position:y", 1000.0, 0.5).from(0.0)
	await get_tree().create_timer(0.8).timeout
	portraits.erase(character)
	portrait.queue_free()

func play_sound(sound_effect: String) -> void:
	var soundres = load("res://assets/sounds/sfx/%s" % sound_effect)
	audio_sfx.stream = soundres
	audio_sfx.play()

### Helpers

func setup_response_timer() -> void:
	timer_start.emit()
	print("TimerStarted")

func stop_timer() -> void:
	timer_stop.emit()
	
func _finish_response_timer():
	#Like...remove all choiced but last in the responses area. 
	#_pick_first_choice()
	_pick_random_choice()
	print("TimerFinished")

func _pick_first_choice():
	next(dialogue_line.responses[0].next_id)

func _pick_random_choice():
	var number_of_children = responses_menu.get_child_count()
	var random_child = randi() % number_of_children
	next(dialogue_line.responses[random_child].next_id)

func _leave_only_first():
	var number_of_children = responses_menu.get_child_count()
	for n in (number_of_children - 1):
		responses_menu.remove_child(responses_menu.get_child(1))

# Set up keyboard movement and signals for the response menu
func configure_menu() -> void:
	balloon.focus_mode = Control.FOCUS_NONE

	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]

		item.mouse_filter = Control.MOUSE_FILTER_STOP
		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item))

	items[0].grab_focus()


# Get a list of enabled items
func get_responses() -> Array:
	var items: Array = []
	for child in responses_menu.get_children():
		if "Disallowed" in child.name: continue
		items.append(child)

	return items


### Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	dialogue_label.modulate.a = 0.0


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return

	item.grab_focus()

func _play_on_hover_sound() -> void:
	print("trying to play sound")
	var soundres = load("res://assets/sounds/sfx/pleasing-bell.wav")
	audio_sfx.stream = soundres
	audio_sfx.play()
	
func _accept_gui_input(event: InputEvent) -> void:
	print("Got here through accept gui input,")
	_play_on_hover_sound()

func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return
	

	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		if input_locked: return
		responses_menu.modulate.a = 0.0
		_play_on_hover_sound()
		next(dialogue_line.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		responses_menu.modulate.a = 0.0
		next(dialogue_line.responses[item.get_index()].next_id)


func _on_balloon_gui_input(event: InputEvent) -> void:
	#my own custom thing
	if input_locked: return
	
	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_finish_pats():
	print("Pats finished!")
	unpause_from_minigame() # Replace with function body.
