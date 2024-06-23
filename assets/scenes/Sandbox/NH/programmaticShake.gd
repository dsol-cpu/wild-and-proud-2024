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

#how much to lerp a second. 
@export var shakeLerpVelocity : float = 0.1

var default_x
var default_y
var target_x: float
var target_y: float
var shakeFreqTimer = 0
var shakeReturnTimer = 0
var shaken: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	default_x = position.x
	default_y = position.y
	target_x = default_x
	target_y = default_y
	pass # Replace with function body.

func _set_shaken_position():
	var random_x = randf_range(-1 * shakeIntensity, 1 * shakeIntensity)
	var random_y = randf_range(0, 1 * shakeIntensity)
	target_x = default_x + random_x
	target_y = default_y + random_y

func _set_default_position():
	target_x = default_x
	target_y = default_y

func _lerp_to_target(t):
	var target_vec = Vector2(target_x, target_y)
	position = position.lerp(target_vec, t)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (shaken):
		_lerp_to_target(shakeReturnTimer / shakeReturnTime)
		shakeReturnTimer += delta
		if (shakeReturnTimer >= shakeReturnTime):
			shakeReturnTimer = randf_range(0, shakeReturnTime / 2)
			_set_default_position()
			shaken = false
	else:
		shakeFreqTimer += delta
		_lerp_to_target(shakeFreqTimer / shakeFrequency)
		if (shakeFreqTimer >= shakeFrequency):
			shakeFreqTimer = randf_range(0, shakeFrequencyVariance)
			_set_shaken_position()
			shaken = true
			
	
