extends Area2D

signal left_screen

@export var speed = 300
# Mystery points
var points_options = [10, 20, 30, 40, 50]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var velocity = Vector2.RIGHT * speed
    position += velocity * delta
    
    
func calculate_points():
    return points_options.pick_random()

func destroy():
    queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
    left_screen.emit()
    queue_free()
