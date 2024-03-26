extends Camera2D

@export var decay := 0.5 # How quickly the screen will stop shaking [0,1]
@export var max_offset := Vector2(100, 75) # Max displacement
@export var noise : FastNoiseLite # The source of random values

var noise_y = 0   # Value to move through the noise
var trauma := 0.0 # Current shake strength
var trauma_power := 3 # Trauma exponent [2,3]


# Called when the node enters the scene tree for the first time.
func _ready():
    randomize()
    noise.seed = randi() 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if trauma:
        trauma = max(trauma - (decay * delta), 0)
        shake()
    
    
func add_trauma(amount : float):
    trauma = min(trauma + amount, 1.0)
    
func shake():
    var amount = pow(trauma, trauma_power)
    noise_y += 1
    offset.x = max_offset.x * amount * noise.get_noise_2d(1000, noise_y)
    offset.y = max_offset.y * amount * noise.get_noise_2d(2000, noise_y)
