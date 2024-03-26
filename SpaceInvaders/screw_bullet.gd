extends Node2D

signal hit(area : Area2D, me : Node2D)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var velocity = Vector2.DOWN * $Projectile.speed
    position += velocity * delta


func _on_spin_timer_timeout():
    $Sprite2D.flip_h = not $Sprite2D.flip_h


func _on_projectile_out_of_bounds():
    queue_free()


func _on_projectile_area_entered(area):
    var aliens = get_tree().get_nodes_in_group("aliens")
    if area.get_parent() not in aliens:
        hit.emit(area, self)
