extends CharacterBody3D

class_name PlayerBody3D

var speed
const WALK_SPEED = 5
const SPRINT_SPEED = 8.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const COLD = 0.1
const COLD_SPRINT = 0.5


#bob
const BOB_FREQ = 2.4
const BOB_AMP = 0.04
var t_bob = 0.1

var gravity = 9.8

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Head/Camera3D/WeaponPivot/hatchet/Hitbox
@onready var flashlight = $Head/SpotLight3D

#Cold
var in_warmth_zone = false
@export var max_cold: float = 100.0
var current_cold: float = max_cold
@export var cold_decrease_rate: float = 1.0
@export var cold_increase_rate: float = 3.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))


func _physics_process(delta: float) -> void:

	#Cold Part 2
	if in_warmth_zone:
		current_cold = min(current_cold + cold_increase_rate * delta, max_cold)
		print(current_cold)
	else:
		current_cold = max(current_cold - cold_decrease_rate * delta, 0)
		print(current_cold)
	if current_cold <= 90:
		print("Player is fucking freezing!")
		print(current_cold)
		speed = WALK_SPEED * 0.5
		speed = SPRINT_SPEED * 0.8
		
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("attack"):
		anim_player.play("attack")
		hitbox.monitoring = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#sprintmaxxing
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED


	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	#headbobbin
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)


	move_and_slide()


func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = sin(time * BOB_FREQ / 2) * BOB_AMP
	return pos


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_player.play("idle")
		hitbox.monitoring = false

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("enemy"):
		print("hit")


func _on_warmth_area_entered(_area: Area3D) -> void:
	in_warmth_zone = true


func _on_warmth_area_exited(_area: Area3D) -> void:
	in_warmth_zone = false
