extends Sprite2D

#in seconds, how often should we shake
@export var shakeFrequency : float = 2
#what random variance should we inject in frequency?
@export var shakeFrequencyVariance : float = 1.5
#Like, how many pixels away from default should it move for each shake
#This is a range, not an absolute, it will be randomly inside this
@export var shakeIntensity : float = 0.25
#after doing a shake, how long should it take to return
@export var shakeReturnTime : float = 0.25
var default_x
var default_y
var shakeFreqTimer = 0
var shakeReturnTimer = 0
var shaken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	default_x = position.x
	default_y = position.y
	pass # Replace with function body.

func _set_shaken_position():
	var random_x = randf_range(-1 * shakeIntensity, 1 * shakeIntensity)
	var random_y = randf_range(0, 1 * shakeIntensity)
	position.x = default_x + random_x
	position.y = default_y + random_y

func _set_default_position():
	position.x = default_x
	position.y = default_y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (shaken):
		shakeReturnTimer += delta
		if (shakeReturnTimer >= shakeReturnTime):
			shakeReturnTimer = randf_range(0, shakeReturnTime / 2)
			_set_default_position()
			shaken = false
	else:
		shakeFreqTimer += delta
		if (shakeFreqTimer >= shakeFrequency):
			shakeFreqTimer = randf_range(0, shakeFrequencyVariance)
			_set_shaken_position()
			shaken = true
			
	
