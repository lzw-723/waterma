extends RigidBody2D

class_name Fruit

const SIZES = [26, 38, 54, 60, 76, 89, 92, 129, 154, 154, 204]

export var i:int = 1
export var r = 0
export var safe_height = 60
export var mscale = 0.6
export onready var wait = 0.6
var crashed = false
var tmp = 0
var state
enum FruitState {WAIT, MOVE, FALL, HIDE}
#{READY, OK, OVER}
var timer
var target_position = Vector2.ZERO

var MyTool = preload("res://mytool.gd")
var mtool

func _ready():
    i = randi() % 5 + 1
    create(true)
    
func create(fresh:bool):
    r = SIZES[i-1] * mscale
    var m = str("res://img/", i, ".png")
    $CollisionShape2D/Sprite.texture = load(m)
    $CollisionShape2D/Sprite.scale = Vector2(mscale, mscale)
    ($CollisionShape2D.shape as CircleShape2D).radius = r
    $juice.scale = Vector2(2*r / 292, 2*r / 319)
    $juice.rotation_degrees = rand_range(0, 360)
    self.mass = r * r * PI
    if fresh:
        state = FruitState.WAIT
    else:
        state = FruitState.FALL
    print_debug(str("create:i:", i, ",r:", r))

func is_waitting():
    return state == FruitState.WAIT
    
func is_moving():
    return state == FruitState.MOVE
    
func is_falling():
    return state == FruitState.FALL

func change_state():
    match state:
        FruitState.WAIT:
            state = FruitState.MOVE
        FruitState.MOVE:
            state = FruitState.FALL
        FruitState.FALL:
            state = FruitState.HIDE
        
func is_crashed():
    return crashed

func _input(event):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT:
            if event.is_pressed() and state == FruitState.WAIT:
                target_position = get_global_mouse_position()
                target_position.x += rand_range(-2, 2)
                if target_position.x < r:
                    target_position.x = r
                if target_position.x + r >= 480:
                    target_position.x = 480 - r - 3
                print_debug(target_position)
                print_debug(str("pos:", global_position))
                target_position.y = global_position.y
                state = FruitState.MOVE
    
#func _process(delta):
#    if target_position and target_position.distance_to(global_position) > 0:
#        global_position = global_position.move_toward(target_position, 20)
#        print("move")

func _physics_process(delta):
    
    if state == FruitState.MOVE:
        if abs(abs(target_position.x) - abs(global_position.x)) > 0:
            global_position = global_position.move_toward(target_position, 20)
        else:
            gravity_scale = 1
            state = FruitState.FALL
            apply_central_impulse(Vector2(0, 6 * weight))
            
#            add_force(Vector2.ZERO, Vector2(98, 98))
    elif state == FruitState.FALL and tmp < wait:
        tmp+=delta
        apply_central_impulse(Vector2(0, 0.6 * weight))
        pass
        
    if crashed:
        if global_position.y <= safe_height:
            if $Timer.is_stopped():
                $Timer.start()
    else:
        $Timer.stop()
        



func _on_fruit_crashed(body):
    if not crashed and is_falling():
        crashed = true
    if body is RigidBody2D:
        if body.r == self.r:
            if i ==  10:
                get_parent().game_win()
                return
            (body as RigidBody2D).contact_monitor = false
            var ve = (body.linear_velocity * body.mass + linear_velocity * mass)
            body.linear_velocity = Vector2.ZERO
            var tween := create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
            tween.tween_property(body, "modulate", Color(1,1,1,0), 0.2)
            tween.connect("finished", body,"s_destroy")
            $juice/AnimationPlayer.play("爆炸")
            $juice/AudioStreamPlayer2D.play(1.9)
            self.i+=1
            create(false)
            scale = Vector2(SIZES[i-1] / SIZES[i], SIZES[i-1] / SIZES[i])
            $CollisionShape2D/Sprite.modulate.a = 0
            tween = create_tween().set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
            tween.tween_property(self, "scale", Vector2(1, 1), 0.2)
            tween.parallel().tween_property($CollisionShape2D/Sprite, "modulate", Color(1,1,1,1), 0.2)
            linear_velocity = ve / mass
            get_parent().impact(global_position)
            get_parent().add_mark(i*i/2)
        else:
#            $CollisionShape2D/Sprite/AudioStreamPlayer2D.global_position = global_position
#            $CollisionShape2D/Sprite/AudioStreamPlayer2D.pitch_scale = 1 - i*0.08
#            $CollisionShape2D/Sprite/AudioStreamPlayer2D.volume_db = -150 + linear_velocity.length()/2
#            $CollisionShape2D/Sprite/AudioStreamPlayer2D.play()
#            print_debug("play")
            pass
#        ($CollisionShape2D.shape as CircleShape2D).radius = r

func s_destroy():
    if is_instance_valid(self) and get_parent() != null:
        get_parent().remove_child(self)
        queue_free()
        pass


func _on_Timer_timeout():
    print_debug("game over")
    pass # Replace with function body.
