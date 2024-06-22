extends ParallaxBackground

var scroll_x = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scroll_x -= 200 * delta
	self.scroll_offset.x = scroll_x
