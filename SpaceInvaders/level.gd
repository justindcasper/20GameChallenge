extends Node2D

signal game_overed

const Invasion = preload("res://invasion.tscn")
const Cannon = preload("res://cannon.tscn")
const Ship = preload("res://ship.tscn")
const Laser_Particles = preload("res://laser_particles.tscn")

const INVASION_LOCATION = Vector2(0, 160)
const INVASION_LEVEL_INCREMENT = 32
const CANNON_LOCATION = Vector2(840, 820)
const SHIP_START = Vector2(0, 80)
const SCORE_FMT = "Score: %05d"
const LIVES_STR = "Lives: "
const CANNON_BBCODE = "[img]res://art/cannon_small.png[/img]"

var invasion
var invasion_count = 0 # Number of invasions defeated
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
    # The invasion should spawn lower each time the player wins
    invasion.position.y += INVASION_LEVEL_INCREMENT * invasion_count
    add_child(invasion)
    invasion.fired.connect(_on_invasion_fired.bind())
    invasion.alien_killed.connect(_on_invasion_alien_killed.bind())
    
    
func spawn_cannon():
    cannon = Cannon.instantiate()
    cannon.position = CANNON_LOCATION
    call_deferred("add_child", cannon)
    cannon.fired.connect(_on_cannon_fired.bind())
    cannon.set_can_fire(true)
    
func spawn_ship():
    ship = Ship.instantiate()
    ship.position = SHIP_START
    add_child(ship)
    ship.left_screen.connect(_on_ship_left_screen.bind())
    

func laser_explode(location : Vector2):
    var particles = Laser_Particles.instantiate()
    particles.position = location
    particles.emitting = true
    add_child(particles)
    await particles.finished
    particles.queue_free()
    
    
func reset_ship_timer():
    $ShipTimer.wait_time = randf_range(2.0, 10.0)
    $ShipTimer.start()
    
    
func game_over():
    # Pause the level
    call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED)
    # Show the Game Over
    $GameOver.show()
    await get_tree().create_timer(2.0).timeout
    # End the game
    game_overed.emit()
    
    

func _on_cannon_fired(laser, location):
    var spawned_laser = laser.instantiate()
    spawned_laser.position = location
    add_child(spawned_laser)
    spawned_laser.hit.connect(_on_laser_hit.bind())


func _on_laser_hit(area : Area2D):
    if invasion == null:
        return
        
    # Get the aliens and get the parent of the area that was hit
    var aliens = invasion.get_children()
    var area_parent = area.get_parent()
    # The location is used for the laser explosion
    var location = area_parent.position + area.position
    # We hit an alien
    if area_parent in aliens:
        $LaserAudio.play()
        invasion.kill_alien(area_parent)
        $ScoreLabel.text = SCORE_FMT % score
        laser_explode(location + invasion.position)
    # We hit the ship
    elif area == ship:
        score += ship.calculate_points()
        $LaserAudio.play()
        $ScoreLabel.text = SCORE_FMT % score
        ship.destroy()
        reset_ship_timer()
        laser_explode(location)


func _on_invasion_fired(projectile, location):
    var spawned_projectile = projectile.instantiate()
    spawned_projectile.position = location
    add_child(spawned_projectile)
    spawned_projectile.add_to_group("projectiles")
    spawned_projectile.hit.connect(_on_alien_projectile_hit.bind())
    
    
func _on_alien_projectile_hit(area : Area2D, projectile : Node2D):
    # The defeat area only effects the aliens to cause a game over
    if area != $DefeatArea:
        projectile.queue_free()
        
    if area == cannon:
        get_tree().call_group("projectiles", "queue_free")
        # To prevent a race condition
        if invasion != null:
            invasion.process_mode = Node.PROCESS_MODE_DISABLED
        # Screen shake
        $Camera.add_trauma(1.0)
        # Get rid of the cannon
        cannon.destroy()
        await cannon.exploded
        
        lives -= 1
        update_lives_label()
        # Same race condition as before
        if invasion != null:
            invasion.process_mode = Node.PROCESS_MODE_ALWAYS
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
    # The player killed all the aliens, set everything up and prevent the cannon
    # from firing until there's a new invasion
    if aliens.size() == 0:
        invasion.queue_free()
        invasion_count += 1
        left_area_initially_entered = true
        right_area_initially_entered = false
        cannon.set_can_fire(false)
        await get_tree().create_timer(1.5).timeout
        spawn_invasion()
        cannon.set_can_fire(true)


# These signals deal with the double boolean state machine to change the
# direction of the invasion
func _on_left_boundary_area_area_entered(_area):
    if not left_area_initially_entered:
        left_area_initially_entered = true
        invasion.reverse()
        right_area_initially_entered = false


func _on_right_boundary_area_area_entered(_area):
    if not right_area_initially_entered:
        right_area_initially_entered = true
        invasion.reverse()
        left_area_initially_entered = false
