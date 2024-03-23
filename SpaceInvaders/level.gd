extends Node2D

signal game_overed

const Invasion = preload("res://invasion.tscn")
const Cannon = preload("res://cannon.tscn")
const Ship = preload("res://ship.tscn")

const INVASION_LOCATION = Vector2(0, 160)
const INVASION_LEVEL_INCREMENT = 32
const CANNON_LOCATION = Vector2(840, 820)
const SHIP_START = Vector2(0, 80)
const SCORE_FMT = "Score: %05d"
const LIVES_STR = "Lives: "
const CANNON_BBCODE = "[img]res://art/cannon_small.png[/img]"

var invasion
var invasion_count = 0
var cannon
var ship
var score = 0
@export var lives = 3

# Sort of state machine with two booleans to determine which way the invasion
# should be moving, and trying to conditionally access the area being entered,
# because we're likely getting several signals
var left_area_initially_entered = true
var right_area_initially_entered = false

# Called when the node enters the scene tree for the first time.
func _ready():
    $ScoreLabel.text = SCORE_FMT % score
    update_lives_label()
    spawn_cannon()
    spawn_invasion()
    reset_ship_timer()
    

func update_lives_label():
    $LivesLabel.text = LIVES_STR
    for i in range(lives):
        $LivesLabel.text += "%s " % CANNON_BBCODE
        
func spawn_invasion():
    invasion = Invasion.instantiate()
    invasion.position = INVASION_LOCATION
    invasion.position.y += INVASION_LEVEL_INCREMENT * invasion_count
    add_child(invasion)
    invasion.fired.connect(_on_invasion_fired.bind())
    invasion.alien_killed.connect(_on_invasion_alien_killed.bind())
    
    
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
    
    
func game_over():
    call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
    $GameOver.show()
    await get_tree().create_timer(2.0).timeout
    game_overed.emit()
    

func _on_cannon_fired(laser, location):
    var spawned_laser = laser.instantiate()
    spawned_laser.position = location
    add_child(spawned_laser)
    spawned_laser.hit.connect(_on_laser_hit.bind())


func _on_laser_hit(area : Area2D):
    var aliens = invasion.get_children()
    var area_parent = area.get_parent()
    if area_parent in aliens:
        invasion.kill_alien(area_parent)
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
    
    
func _on_alien_projectile_hit(area : Area2D, projectile : Node2D):
    if area != $DefeatArea:
        projectile.queue_free()
        
    if area == cannon:
        cannon.destroy()
        lives -= 1
        update_lives_label()
        if lives > 0:
            spawn_cannon()
        else:
            game_over()

        

func _on_ship_timer_timeout():
    spawn_ship()
    
    
func _on_ship_left_screen():
    reset_ship_timer()


func _on_defeat_area_area_entered(area):
    var area_parent = area.get_parent()
    var aliens = get_tree().get_nodes_in_group("aliens")
    if area_parent in aliens:
        game_over()
        
        
func _on_invasion_alien_killed(points : int):
    score += points
    var aliens = get_tree().get_nodes_in_group("aliens")
    if aliens.size() == 0:
        invasion.queue_free()
        invasion_count += 1
        left_area_initially_entered = true
        right_area_initially_entered = false
        spawn_invasion()


# These signals deal with the double boolean state machine to change the
# direction of the invasion
func _on_left_boundary_area_area_entered(area):
    if not left_area_initially_entered:
        left_area_initially_entered = true
        invasion.reverse()
        right_area_initially_entered = false


func _on_right_boundary_area_area_entered(area):
    if not right_area_initially_entered:
        right_area_initially_entered = true
        invasion.reverse()
        left_area_initially_entered = false
