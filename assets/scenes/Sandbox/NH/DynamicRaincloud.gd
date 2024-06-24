extends Node2D

@onready var particleSetup: CPUParticles2D = $RainParticles

var defaultAmount: int = 50
var defaultVelocity: float = 700

var lightAmount: int = 20
var lightVelocity: float = 300

var heavyAmount: int = 100
var heavyVelocity: float = 1000

var testTimer: float = 0
var testTimerMax: float = 4

var rainFuncList

func _ready():
	rainFuncList = ["_defaultRain", "_lightRain", "_heavyRain"]
	

func _updateAmount(newAmount) -> void:
	particleSetup.amount = newAmount

func _updateVelocity(newVelocity) -> void:
	particleSetup.initial_velocity_max = newVelocity
	particleSetup.initial_velocity_min = newVelocity
	
func _defaultRain() -> void:
	#_updateAmount(defaultAmount)
	_updateVelocity(defaultVelocity)
	
func _lightRain() -> void:
	#_updateAmount(lightAmount)
	_updateVelocity(lightVelocity)
	
func _heavyRain() -> void:
	#_updateAmount(heavyAmount)
	_updateVelocity(heavyVelocity)
	
func _process(delta):
	testTimer += delta
	if (testTimer > testTimerMax):
		testTimer = 0
		var i = randi() % rainFuncList.size()
		call(rainFuncList[i])
	
