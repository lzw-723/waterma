extends Node2D

var Fruit = preload("res://fruit.tscn")
var fruit
var mark:int = 0
var pos = Vector2(240, 0)
const wait_time = 2.5
var tmp = wait_time
func _ready():
    randomize()
    $AnimationPlayer.play("出现动画")
    pass # Replace with function body.
    
func _input(event):
    if event.is_action_pressed("ui_cancel") or $mask/PopupDialog/TextureButton.is_pressed():
        get_tree().paused = !get_tree().paused
        if get_tree().paused:
            $mask.visible = true
            $mask/ColorRect/WindowDialog.popup()
        else:
            $mask.visible = false
            $mask/WindowDialog.hide()
    pass
    
func _process(delta):
#    if Input.is_action_pressed("ui_cancel"):
#        get_tree().paused = true
    pass
    
func _physics_process(delta):
#    _process(delta):
#    if tmp >= wait_time:
     if fruit == null or not is_instance_valid(fruit) or (fruit.is_falling() and fruit.is_crashed()):
        fruit = Fruit.instance()
        tmp = 0
        add_child(fruit)
        pos.y = fruit.r + 2
        fruit.global_position = pos
     if not is_instance_valid(fruit) or fruit.is_falling():
        tmp += delta
        pass

func _on_fruit_entered(body):
    if body.is_crashed():
        $Area2D/top.set_visible(true)
        pass # Replace with function body.
    
    
func add_mark(value:int = 0):
    $AnimationPlayer.play("加分动画")
    mark+=value
    $Area2D/Label.text = str("得分：", mark)

func impact(pos:Vector2):
    $AudioStreamPlayer2D.global_position = pos
#    $AudioStreamPlayer2D.play()

func _on_fruit_exited(body):
    $Area2D/top.set_visible(false)
    pass # Replace with function body.
    
func game_over():
    get_tree().paused

func game_win():
    $audio_win.play()
