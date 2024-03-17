extends Node2D

@export var projectile_speed = 500


# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_cannon_fired(laser, location):
    var spawned_laser = laser.instantiate()
    spawned_laser.position = location
    add_child(spawned_laser)
    spawned_laser.hit.connect(_on_laser_hit.bind())

func _on_laser_hit(area : Area2D):
    var aliens = get_tree().get_nodes_in_group("aliens")
    var area_parent = area.get_parent()
    if area_parent in aliens:
        area_parent.queue_free()
