extends Button
class_name QuitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _pressed():
	get_tree().quit()
