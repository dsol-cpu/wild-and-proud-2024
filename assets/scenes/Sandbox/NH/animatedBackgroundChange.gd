extends AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	_transition_animation_go()
	#self.animation_looped

func _transition_animation_go():
	self.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
