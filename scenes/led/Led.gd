extends Node2D

@export var on = false
@export_enum("green", "red", "yellow", "blue") var color: String = "green"
@export var tag = 'X.X'
@export var opis = 'opis'

func _ready():
	update()

func _process(delta):
	if on==false:
		$AnimatedSprite.animation="white"
	elif on==true:
		$AnimatedSprite.animation=color	

func update():
	$labTag.text = tag
	$labOpis.text = opis
