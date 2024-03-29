extends ScreenwrappedRigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
    
func _draw():
    draw_circle(Vector2.ZERO, 4.0, Color.GREEN)


func _on_timer_to_live_timeout():
    queue_free()
