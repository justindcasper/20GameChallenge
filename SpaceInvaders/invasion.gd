extends Node2D

const Octopus = preload("res://octopus.tscn")
const Crab = preload("res://crab.tscn")
const Squid = preload("res://squid.tscn")
const ALIENS_PER_ROW = 11
const ROW_HEIGHT = 80
const ALIEN_WIDTH = 84
const MARGIN = 32
const ADVANCE_STEP = 58

var screen_size
var invasion_width
var advance_step = ADVANCE_STEP

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    generate_invasion()
    $AdvanceTimer.start()


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
    var drop = false
    if advance_step > 0:
        if position.x + invasion_width >= screen_size.x - MARGIN:
            drop = true
    else:
        if position.x <= MARGIN:
            drop = true
            
    if drop:
        position.y += ADVANCE_STEP
        advance_step *= -1
    else:
        position.x += advance_step


func _on_advance_timer_timeout():
    advance()
