extends CharacterBody2D

const ACCELERATION = 10
const MAX_SPEED = 80
const FRICTION = 10

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE

@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

func _ready():
	animation_tree.active = true

func _physics_process(delta):
	match state:
		MOVE: move_state()
		ROLL: roll_state()
		ATTACK: attack_state()

#desc Code running while in MOVE state
func move_state():
	var input_vector = input_to_velocity()
	animate(input_vector)
	move_and_slide()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

#desc Code running while in ROLL state
func roll_state():
	pass

#desc Code running while in ATTACK state
func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("PlayerAttack")

#desc Signal handler to switch back to MOVE state after attack animation ends
func _on_animation_tree_animation_finished(anim_name: String):
	if anim_name.begins_with("PlayerAttack"):
		state = MOVE

#desc Calculates an input vector from movement inputs and updates the velocity
func input_to_velocity():
	var input_vector = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down")).normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	return input_vector

#desc Handles the animation from input vector
func animate(input_vector):
	if input_vector == Vector2.ZERO:
		animation_state.travel("PlayerIdle")
		return
		
	animation_tree.set("parameters/PlayerIdle/blend_position", input_vector)
	animation_tree.set("parameters/PlayerRun/blend_position", input_vector)
	animation_tree.set("parameters/PlayerAttack/blend_position", input_vector)
	animation_state.travel("PlayerRun")
