extends Node

const Space = preload("res://space.tscn")

var main_menu
var space

# Called when the node enters the scene tree for the first time.
func _ready():
    main_menu = $MainMenu


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass


func _on_main_menu_start_button_pressed():
    space = Space.instantiate()
    remove_child(main_menu)
    add_child(space)
    space.game_overed.connect(_on_space_game_overed.bind())
    
    
func _on_space_game_overed():
    space.queue_free()
    add_child(main_menu)
