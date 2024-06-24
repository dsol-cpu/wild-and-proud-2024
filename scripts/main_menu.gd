extends Control
class_name MainMenu

@export var main_path : NodePath

@onready var main : Node = get_node(main_path)
var game_scene : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	game_scene = preload("res://examples/test_scenes/visual_novel_scene.tscn").instantiate()

func start_game():
	main.add_child(game_scene)
