extends Node2D

signal hit(area : Area2D)

var fully_fired = false

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    var velocity = Vector2.UP * $Projectile.speed
    position += velocity * delta


func _on_projectile_area_exited(area):
    # We have to leave the cannon fully
    fully_fired = true


func _on_projectile_area_entered(area):
    if fully_fired:
        queue_free()
        
    hit.emit(area)


func _on_projectile_out_of_bounds():
    queue_free()
