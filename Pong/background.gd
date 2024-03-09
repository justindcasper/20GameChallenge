extends ColorRect


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
    #pass

func _draw():
    draw_dashed_line(Vector2(960, 160), Vector2(960, 1016), Color.WHITE, 4, 16)
    
