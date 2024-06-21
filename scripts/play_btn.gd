extends Button
class_name PlayButton

@export var m_menu_path : NodePath
@onready var m_menu : MainMenu = get_node(m_menu_path)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	# Hide the main menu
	m_menu.hide()
	# Transition to the next scene
	m_menu.start_game()
