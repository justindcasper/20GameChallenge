extends Node2D

signal fired(projectile, location)
signal alien_killed(points : int)

const Octopus = preload("res://octopus.tscn")
const Crab = preload("res://crab.tscn")
const Squid = preload("res://squid.tscn")
const Screw_Bullet = preload("res://screw_bullet.tscn")
const Bomb = preload("res://bomb.tscn")

const ALIENS_PER_ROW = 11
const ROW_HEIGHT = 80
const ALIEN_WIDTH = 84
const MARGIN = 32
const ADVANCE_STEP = 58
const PROJECTILES = [Screw_Bullet, Bomb]
const SPEED_UP_PERCENTAGE = 0.03

var screen_size
var invasion_width
var advance_step = ADVANCE_STEP

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    generate_invasion()
    get_tree().call_group("aliens", "play")
    $AdvanceTimer.start()
    $FireTimer.wait_time = randf_range(0.5, 4.0)
    $FireTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
    

func generate_row(row : int, alien_prefab : PackedScene):
    var x_pos = MARGIN
    var y_pos = row * ROW_HEIGHT
        
    for i in range(ALIENS_PER_ROW):
        var alien = alien_prefab.instantiate()
        alien.position = Vector2(x_pos, y_pos)
        add_child(alien)
        alien.add_to_group("aliens")
        x_pos += ALIEN_WIDTH + MARGIN
        
    return x_pos
    
func generate_invasion():
    var width_values = [
        generate_row(0, Squid),
        generate_row(1, Crab),
        generate_row(2, Crab),
        generate_row(3, Octopus),
        generate_row(4, Octopus),
    ]
    invasion_width = width_values.max()
    
func advance():
    # Should we drop down a level?
    var drop = false
    # Are we moving right?
    if advance_step > 0:
        # Are we by the right edge of the screen?
        if position.x + invasion_width >= screen_size.x - MARGIN:
            drop = true
    # Are we moving left?
    else:
        # Are we by the left edge of the screen?
        if position.x <= MARGIN:
            drop = true
            
    if drop: # By a screen edge, so drop and reverse directions
        position.y += ADVANCE_STEP
        advance_step *= -1
    else: # Just move normally
        position.x += advance_step

func choose_random_alien():
    var random_child = get_children().pick_random()
    if random_child is Timer:
        return null
    else:
        return random_child
        
func drop_projectile():
    var alien = choose_random_alien()
    if alien != null:
        var center_location = alien.get_node("Alien").position
        var location = alien.position + center_location + position
        fired.emit(PROJECTILES.pick_random(), location)
        
func kill_alien(alien : Node2D):
    var points = alien.get_value()
    alien.queue_free()
    # Go faster
    $AdvanceTimer.wait_time *= 1 - SPEED_UP_PERCENTAGE
    get_tree().call_group("aliens", "speed_up", SPEED_UP_PERCENTAGE)
    await get_tree().process_frame
    alien_killed.emit(points)

func _on_advance_timer_timeout():
    advance()
    

func _on_fire_timer_timeout():
    $FireTimer.wait_time = randf_range(0.2, 2.0)
    drop_projectile()
