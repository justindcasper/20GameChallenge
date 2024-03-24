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

const INITIAL_NOTE_TIMESTAMP = 0.0
const FINAL_NOTE_TIMESTAMP = 3.0

var advance_step = ADVANCE_STEP
var should_drop = false
var seek_timestamp = INITIAL_NOTE_TIMESTAMP

# Called when the node enters the scene tree for the first time.
func _ready():
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
    generate_row(0, Squid)
    generate_row(1, Crab)
    generate_row(2, Crab)
    generate_row(3, Octopus)
    generate_row(4, Octopus)
    
func increment_seek_timestamp():
    if seek_timestamp == FINAL_NOTE_TIMESTAMP:
        seek_timestamp = INITIAL_NOTE_TIMESTAMP
    else:
        seek_timestamp += 1.0
        
    
func advance():
    if should_drop: # By a screen edge, so drop and reverse directions
        position.y += ADVANCE_STEP
        should_drop = false
    else: # Just move normally
        position.x += advance_step
        
# Called externally by the level
func reverse():
    advance_step *= -1
    should_drop = true

func choose_random_alien():
    var random_child = get_children().pick_random()
    if random_child is Timer:
        return null
    else:
        return random_child
        
func drop_projectile():
    var alien = choose_random_alien()
    if alien != null:
        var _alien = alien.get_node("Alien")
        if _alien != null:
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
    $Music.play(seek_timestamp)
    increment_seek_timestamp()
    advance()
    $MusicTimer.start()
    

func _on_fire_timer_timeout():
    $FireTimer.wait_time = randf_range(0.2, 2.0)
    drop_projectile()


func _on_music_timer_timeout():
    $Music.stop()
