extends Node2D

const Ship = preload("res://ship.tscn")

var ship

# Called when the node enters the scene tree for the first time.
func _ready():
    spawn_ship()



func spawn_ship():
    ship = Ship.instantiate()
    add_child(ship)
    ship.fired.connect(_on_ship_fired.bind())
    
    
func _on_ship_fired(bullet_prefab : PackedScene, location : Vector2, velocity : Vector2):
    var bullet = bullet_prefab.instantiate()
    bullet.position = location
    add_child(bullet)
    bullet.apply_impulse(velocity)
