extends ScreenwrappedRigidBody2D

var in_transit := false
    
    
func _draw():
    draw_circle(Vector2.ZERO, 4.0, Color.GREEN)


func _on_timer_to_live_timeout():
    queue_free()


func _on_body_entered(_body):
    if in_transit:
        queue_free()


func _on_body_exited(_body):
    in_transit = true
