extends Node2D

signal hit(area : Area2D)

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var velocity = Vector2.DOWN * $Projectile.speed
    position += velocity * delta


func _on_spin_timer_timeout():
    $Sprite2D.flip_v = not $Sprite2D.flip_v


func _on_projectile_out_of_bounds():
    queue_free()


func _on_projectile_area_entered(area):
    var aliens = get_tree().get_nodes_in_group("aliens")
    if area.get_parent() not in aliens:
        queue_free()
        hit.emit(area)
