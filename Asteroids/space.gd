extends Node2D

const Ship = preload("res://ship.tscn")
const Packed_Asteroid = preload("res://asteroid.tscn")

# Maybe the medium size should be the most common
const BIG_ASTEROID_SIZE = 60.0
const MEDIUM_ASTEROID_SIZE = 35.0
const SMALL_ASTEROID_SIZE = 25.0
const ASTEROID_SIZES = [
    SMALL_ASTEROID_SIZE,
    MEDIUM_ASTEROID_SIZE,
    MEDIUM_ASTEROID_SIZE,
    MEDIUM_ASTEROID_SIZE,
    BIG_ASTEROID_SIZE
]

const ASTEROID_FORCE_MAGNITUDE_MIN = 200.0
const ASTEROID_FORCE_MAGNITUDE_MAX = 1000.0

var ship
var ship_last_position : Vector2 # Set when the ship dies after this initial value
var screen_size : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    ship_last_position = Vector2(screen_size.x / 2, screen_size.y / 2)
    spawn_ship()


func spawn_ship():
    ship = Ship.instantiate()
    add_child(ship)
    ship.fired.connect(_on_ship_fired.bind())
    ship.exploded.connect(_on_ship_exploded.bind() )
    
    
func spawn_asteroid(radius : float, location : Vector2, force : Vector2):
    var asteroid = Packed_Asteroid.instantiate()
    asteroid.radius = radius
    asteroid.position = location
    add_child(asteroid)
    asteroid.broke.connect(_on_asteroid_broke.bind())
    asteroid.add_to_group("asteroids")
    # Apply a constant force to the asteroid
    asteroid.add_constant_force(force)
    
    
func _on_ship_fired(bullet_prefab : PackedScene, location : Vector2, velocity : Vector2):
    var bullet = bullet_prefab.instantiate()
    bullet.position = location
    add_child(bullet)
    bullet.apply_impulse(velocity)


func _on_asteroid_timer_timeout():
    # We don't want asteroids to spawn on the visible screen
    var x : float = 0.0
    while x >= 0 and x <= screen_size.x:
        var half_screen_x = screen_size.x / 2
        x = randf_range(-half_screen_x, screen_size.x + half_screen_x)
    var y : float = 0.0
    while y >= 0 and y <= screen_size.y:
        var half_screen_y = screen_size.y / 2
        y = randf_range(-half_screen_y, screen_size.y + half_screen_y)
        
    var asteroid_position = Vector2(x, y)
    var ship_position : Vector2
    var asteroid_force : Vector2
    # To avoid condition where the timer goes off and the ship is dead
    if ship == null:
        ship_position = ship_last_position
    else:
        ship_position = ship.position
        
    asteroid_force = (ship_position - asteroid_position).normalized() * \
            randf_range(ASTEROID_FORCE_MAGNITUDE_MIN, ASTEROID_FORCE_MAGNITUDE_MAX)
    spawn_asteroid(ASTEROID_SIZES.pick_random(), asteroid_position, asteroid_force)
    
    
func _on_asteroid_broke(body : Asteroid):
    var radius = body.radius
    match radius:
        BIG_ASTEROID_SIZE:
            body.radius = MEDIUM_ASTEROID_SIZE
        MEDIUM_ASTEROID_SIZE:
            body.radius = SMALL_ASTEROID_SIZE
        SMALL_ASTEROID_SIZE:
            body.destroy()
        _:
            body.destroy()
            
            
func _on_ship_exploded(location : Vector2):
    ship_last_position = location
    ship.destroy()
    $AsteroidTimer.stop()
    await get_tree().create_timer(1.5).timeout
    get_tree().call_group("asteroids", "destroy")
    await get_tree().create_timer(1.0).timeout
    spawn_ship()
    $AsteroidTimer.start()
