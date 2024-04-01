extends RigidBody2D
class_name Asteroid

signal broke(body : Asteroid)

var seen_by_player := false
var outline : PackedVector2Array
var local_collision_pos := Vector2.ZERO
var screen_size : Vector2
## The "average" radius of the asteroid. Setting it changes the mass and number of points
## accordingly.
@export var radius := 25.0 :
    set(value):
        radius = value
        mass = pow(value, 2) / 1000
        take_physical_form()
    get:
        return radius


# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    take_physical_form()
    

# Called every frame
func _process(_delta):
    if seen_by_player and off_screen():
        queue_free()
    if not seen_by_player and not off_screen():
        seen_by_player = true
    
    

func off_screen() -> bool:
    if position.x < 0:
        return true
    if position.x > screen_size.x:
        return true
    if position.y < 0:
        return true
    if position.y > screen_size.y:
        return true
        
    return false
    
    
func take_physical_form():
    outline = generate_shape()
    $Polyline2D.call_deferred("set_points", outline)
    $CollisionPolygon2D.call_deferred("set_polygon", outline)


# Generates a random polygon to use as the asteroid shape, in a roughly circular
# shape
func generate_shape() -> PackedVector2Array:
    var points_num := int(radius / 5) # Number of points on the polygon
    var min_radius := radius * 0.75
    var max_radius := radius * 1.25
    var shape_array : PackedVector2Array = []
    # In radians, how much to step to make a full rotation
    var angle_step = TAU / points_num
    for i in range(points_num):
        var target_angle = angle_step * i; # Get the radians to get to the next point
        # Randomly vary the angle so it's not equally spaced
        var angle = target_angle + ((randf_range(0.0, 1.0) - 0.5) * angle_step * 0.25)
        # Randomly vary the radius of the point between min_radius and max_radius
        var point_radius = min_radius + (randf_range(0.0, 1.0) * (max_radius - min_radius))
        # Turn the angle and the radius into an actual point, and add it to the array
        var x = cos(angle) * point_radius
        var y = sin(angle) * point_radius
        shape_array.append(Vector2(x, y))
            
    # Add the origin point to the end so that the shape closes up
    if shape_array.size() > 0:
        shape_array.append(shape_array[0])
    return shape_array


func destroy():
    $Polyline2D.queue_free()
    $CollisionPolygon2D.queue_free()
    if $ExplosionParticles.emitting:
        await $ExplosionParticles.finished
    queue_free()
    

func _on_body_entered(body):
    if not (body is Asteroid):
        $ExplosionParticles.emitting = true
        broke.emit(self)
