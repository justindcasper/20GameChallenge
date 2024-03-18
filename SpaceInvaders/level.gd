extends Node2D

const Cannon = preload("res://cannon.tscn")
const cannon_location = Vector2(840, 820)

var cannon

# Called when the node enters the scene tree for the first time.
func _ready():
    spawn_cannon()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    
    
func spawn_cannon():
    cannon = Cannon.instantiate()
    cannon.position = cannon_location
    add_child(cannon)
    cannon.fired.connect(_on_cannon_fired.bind())


func _on_cannon_fired(laser, location):
    var spawned_laser = laser.instantiate()
    spawned_laser.position = location
    add_child(spawned_laser)
    spawned_laser.hit.connect(_on_laser_hit.bind())


func _on_laser_hit(area : Area2D):
    var aliens = $Invasion.get_children()
    var area_parent = area.get_parent()
    if area_parent in aliens:
        $Invasion.remove_child(area_parent)
        area_parent.queue_free()


func _on_invasion_fired(projectile, location):
    var spawned_projectile = projectile.instantiate()
    spawned_projectile.position = location
    add_child(spawned_projectile)
    spawned_projectile.hit.connect(_on_alien_projectile_hit.bind())
    
    
func _on_alien_projectile_hit(area : Area2D):
    if area == cannon:
        cannon.destroy()
        spawn_cannon()
        
