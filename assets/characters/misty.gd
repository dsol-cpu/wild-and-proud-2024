extends Node2D

@export var neutralImage: Texture2D
@export var happyImage: Texture2D
@export var sadImage: Texture2D
@export var surprisedImage: Texture2D
@onready var portrait_sprite: Sprite2D = $portrait_sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func set_portrait(portrait: String) -> void:
	if (portrait == "neutral"):
		portrait_sprite.texture = neutralImage
	if (portrait == "happy"):
		portrait_sprite.texture = happyImage
	if (portrait == "sad"):
		portrait_sprite.texture = sadImage
	if (portrait == "surprised"):
		portrait_sprite.texture = surprisedImage

func play_anim(anim_text: String) -> void:
	anim_player.play(anim_text)
	
func bounce() -> void:
	play_anim("bounce")
	
func shake() -> void:
	play_anim("shake")
