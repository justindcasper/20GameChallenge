extends Node2D

const Cannon = preload("res://cannon.tscn")
const Ship = preload("res://ship.tscn")
const CANNON_LOCATION = Vector2(840, 820)
const SHIP_START = Vector2(0, 80)
const SCORE_FMT = "Score: %05d"
const LIVES_STR = "Lives: "
const CANNON_BBCODE = "[img]res://art/cannon_small.png[/img]"

var cannon
var ship
var score = 0
@export var lives = 3

# Called when the node enters the scene tree for the first time.
func _ready():
    $ScoreLabel.text = SCORE_FMT % score
    update_lives_label()
    spawn_cannon()
    reset_ship_timer()
    print($LivesLabel.text.length())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    

func update_lives_label():
    $LivesLabel.text = LIVES_STR
    for i in range(lives):
        $LivesLabel.text += "%s " % CANNON_BBCODE
    
func spawn_cannon():
    cannon = Cannon.instantiate()
    cannon.position = CANNON_LOCATION
    call_deferred("add_child", cannon)
    cannon.fired.connect(_on_cannon_fired.bind())
    
func spawn_ship():
    ship = Ship.instantiate()
    ship.position = SHIP_START
    add_child(ship)
    ship.left_screen.connect(_on_ship_left_screen.bind())
    
    
func reset_ship_timer():
    $ShipTimer.wait_time = randf_range(2.0, 10.0)
    $ShipTimer.start()


func _on_cannon_fired(laser, location):
    var spawned_laser = laser.instantiate()
    spawned_laser.position = location
    add_child(spawned_laser)
    spawned_laser.hit.connect(_on_laser_hit.bind())


func _on_laser_hit(area : Area2D):
    var aliens = $Invasion.get_children()
    var area_parent = area.get_parent()
    if area_parent in aliens:
        score += $Invasion.kill_alien(area_parent)
        $ScoreLabel.text = SCORE_FMT % score
    elif area == ship:
        score += ship.calculate_points()
        $ScoreLabel.text = SCORE_FMT % score
        ship.destroy()
        reset_ship_timer()


func _on_invasion_fired(projectile, location):
    var spawned_projectile = projectile.instantiate()
    spawned_projectile.position = location
    add_child(spawned_projectile)
    spawned_projectile.hit.connect(_on_alien_projectile_hit.bind())
    
    
func _on_alien_projectile_hit(area : Area2D):
    if area == cannon:
        cannon.destroy()
        lives -= 1
        update_lives_label()
        if lives > 0:
            spawn_cannon()
        

func _on_ship_timer_timeout():
    spawn_ship()
    
    
func _on_ship_left_screen():
    reset_ship_timer()
