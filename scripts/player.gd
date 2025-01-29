extends CharacterBody3D

class_name Player

signal cold_updated(new_cold: float)
@warning_ignore("unused_signal")

var speed
const WALK_SPEED = 5
const SPRINT_SPEED = 8.5
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.001
var t_bob = 0.1
var gravity = 9.8

#cold
@export var max_cold: float = 100.0
var current_cold: float = max_cold
@export var cold_decrease_rate: float = 1.0
@export var cold_increase_rate: float = 3.0
var in_warmth_zone = false
var damage_timer: float = 0.0

#health
@export var max_health: int = 100
var health: int = max_health
@export var cold_damage: int = 5
@export var damage_tick_rate: float = 1.0

#player nodes
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $Head/Camera3D/WeaponPivot/hatchet/Hitbox
@onready var level = $".."

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("cold_updated", current_cold)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if in_warmth_zone:
		current_cold = min(current_cold + cold_increase_rate * delta, max_cold)
	else:
		current_cold = max(current_cold - cold_decrease_rate * delta, 0)

	emit_signal("cold_updated", current_cold)

	if current_cold == 0:
		damage_timer += delta
		if damage_timer >= damage_tick_rate:
			apply_health_damage()
			damage_timer = 0.0
	else:
		damage_timer = 0.0

	handle_gravity(delta)
	handle_movement(delta)

	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

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

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

func apply_health_damage() -> void:
	health -= cold_damage
	health = max(health, 0)
	if health <= 95:
		on_player_death()

func on_player_death() -> void:
	print("Player has died!")
	if anim_player.has_animation("death"):
		anim_player.play("death")
		await anim_player.animation_finished
	else:
		print("Warning: No 'death' animation found!")

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * 2.4) * 0.04
	pos.x = sin(time * 2.4 / 2) * 0.04
	return pos

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		anim_player.play("attack")
		hitbox.monitoring = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		anim_player.play("idle")
		hitbox.monitoring = false

func _on_warmth_area_entered(_area: Area3D) -> void:
	in_warmth_zone = true

func _on_warmth_area_exited(_area: Area3D) -> void:
	in_warmth_zone = false
