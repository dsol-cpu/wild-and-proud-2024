extends Node2D

var savedNode

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func meow() -> void:
	animation_player.play("Meow")
	
func setup_signal_link(balloonNode) -> void:
	savedNode = balloonNode

func finishPats() -> void:
	savedNode.emit_signal("finish_pats")
