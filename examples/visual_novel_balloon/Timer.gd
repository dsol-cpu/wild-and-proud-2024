extends ColorRect

var defaultScale: float = 1
var minScale: float = 0
var timerDefault: float = 5
var timerValue
var timerActive: bool = false
@onready var pTopBalloon: Node2D = $VisualNovelBalloon
signal timerFinished

# Called when the node enters the scene tree for the first time.
func _ready():
	timerValue = timerDefault

func _start_timer():
	timerValue = timerDefault
	timerActive = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (timerActive):
		self.scale.x = timerValue / timerDefault
		timerValue -= delta
		if (timerValue <= 0):
			timerActive = false
			timerFinished.emit()
			


func _on_visual_novel_balloon_timer_start():
	_start_timer()
	# Replace with function body.
