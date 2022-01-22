extends KinematicBody

var speed = 10
var acceleration = 5

var mouse_sensitivity = 0.1

var direction = Vector3()
var velocity = Vector3()

onready var pivot = $Pivot


# Object
var collider = null
var previous_collider = null
var picked_up = null
var throw_force: float = 200


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		pivot.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-90), deg2rad(90))


func _process(delta):
	direction = Vector3()

	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x

	direction = direction.normalized()
	velocity = direction * speed
	velocity.linear_interpolate(velocity, acceleration * delta)
	move_and_slide(velocity, Vector3.UP)

	if Input.is_action_just_pressed("exit"):
		get_tree().quit()

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _physics_process(_delta):
	if $Pivot/Camera/RayCast.is_colliding() && !picked_up:
		collider = $Pivot/Camera/RayCast.get_collider()
		if collider != previous_collider && previous_collider:
			previous_collider = collider
		else:
			previous_collider = collider


	if Input.is_action_just_pressed("pick"):
		if !collider or (collider && !collider.has_method("pick_up")):
			var bodies = $PickArea.get_overlapping_bodies()
			if !bodies: return
			var smallest_dist = 100000
			var closest_object = null

			for body in bodies:
				var dist = global_transform.origin.distance_to(body.global_transform.origin)
				if dist < smallest_dist && body.has_method("pick_up"): 
					smallest_dist = dist
					closest_object = body

			if picked_up: return
			elif closest_object:
				closest_object.pick_up($Pivot/PickPoint)
				picked_up = closest_object

		else:
			if picked_up: return
			elif collider.has_method("pick_up"):
				collider.pick_up($Pivot/PickPoint)
				picked_up = collider

	if Input.is_action_just_pressed("throw"):
		if !picked_up: return
		picked_up.let_go(-$Pivot/PickPoint.global_transform.basis.z * throw_force)
		picked_up = null

	if Input.is_action_pressed("shield"):
		pass
