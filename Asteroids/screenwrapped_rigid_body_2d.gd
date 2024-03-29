extends RigidBody2D
class_name ScreenwrappedRigidBody2D


@onready var screen_size := get_viewport_rect().size


func _physics_process(_delta):
    position.x = wrapf(position.x, 0, screen_size.x)
    position.y = wrapf(position.y, 0, screen_size.y)
