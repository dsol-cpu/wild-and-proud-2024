extends Area2D

var times_pat: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _mouse_enter():
	#print("mouse entered")
	times_pat = times_pat + 1
	get_parent().meow()
	#get_node("/root/DialogueManager
	#oh gosh this is so cursed
	#parent1: coco
	#parent2: slot
	#parent3: VisualNovelBalloon
	#var a = get_node("/root/VisualNovelScene/VisualNovelBalloon")
	#print(a.get_class())
	#a.emit_signal("coco_pat_complete")
	#get_parent().get_parent().get_parent().get_node_and_resource()
	if times_pat == 3:
		get_parent().finishPats()
		#print("do a callback thing")
	pass

func _mouse_exit():
	#print("mouse left")
	pass
