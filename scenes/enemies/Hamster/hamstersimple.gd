extends AnimatedSprite2D
@export var hide : bool 

# Called when the node enters the scene tree for the first time.
func _ready():
	if hide == true:
		visible  = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
