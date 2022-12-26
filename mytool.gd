tool
extends Object


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var n:int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
    
    print_debug("toool")
    pass # Replace with function body.
    
func get_random(x:int):
    randomize()
    var i = randi() % x + 1
    while i==n:
        i = randi() % x + 1
    n = i
    return i

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#    pass
