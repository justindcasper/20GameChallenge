extends Node2D

signal brick_broke(points : int)
signal emptied

const Brick = preload("res://brick.tscn")
const BRICKS_PER_ROW = 16
const BRICK_LENGTH = 108
const BRICK_HEIGHT = 32
const BRICK_PADDING = 5

const COLORS = [
    Color.RED,
    Color.ORANGE,
    Color.YELLOW,
    Color.GREEN,
    Color.BLUE,
    Color.INDIGO,
    Color.VIOLET
]
const COLORS_TO_PITCH_SCALE = {
    Color.RED : 2.0,
    Color.ORANGE : 1.889,
    Color.YELLOW : 1.667,
    Color.GREEN : 1.5,
    Color.BLUE : 1.333,
    Color.INDIGO : 1.25,
    Color.VIOLET : 1.125,
}
const COLORS_TO_POINTS = {
    Color.RED : 7,
    Color.ORANGE : 6,
    Color.YELLOW : 5,
    Color.GREEN : 4,
    Color.BLUE : 3,
    Color.INDIGO : 2,
    Color.VIOLET : 1,
}


# Called when the node enters the scene tree for the first time.
func _ready():
    lay_bricks()
    #lay_bricks_in_row(Color.RED, 0)
    
    
func lay_bricks_in_row(color : Color, row : int):
    # The y position is the same across the row obviously
    var row_pos_y = row * (BRICK_HEIGHT + (BRICK_PADDING * 2))
    for i in range(BRICKS_PER_ROW):
        var brick = Brick.instantiate()
        # Set the new brick's position in an evenly spaced grid
        brick.position.x = position.x + ((BRICK_LENGTH + BRICK_PADDING) * i) +\
            (BRICK_PADDING * (i + 1))
        brick.position.y = row_pos_y
        # Add to scene tree and set the color
        add_child(brick)
        brick.get_node("ColorRect").color = color

func lay_bricks():
    for i in range(COLORS.size()):
        lay_bricks_in_row(COLORS[i], i)
        
func break_brick(brick):
    var brick_color = brick.get_node("ColorRect").color
    $SoundPlayer.pitch_scale = COLORS_TO_PITCH_SCALE[brick_color]
    $SoundPlayer.play()
    brick_broke.emit(COLORS_TO_POINTS[brick_color])
    brick.queue_free()
    # If we drop below two children, all that's left is $SoundPlayer
    # Remember that the freeing is only done at the end of the current frame
    if get_children().size() <= 2:
        # Player won this round
        emptied.emit()
    
func clear_bricks():
    for child in get_children():
        if child != $SoundPlayer:
            child.queue_free()
