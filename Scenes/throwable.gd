extends RigidBody

onready var original_parent = get_parent()

var picked_up_by = null
var speed = 5.0
var original_transform


func _ready():
	pass


func _physics_process(delta):
	if !picked_up_by: return

	global_transform.origin = lerp(global_transform.origin, picked_up_by.global_transform.origin, speed * delta)


func pick_up(by):
	if picked_up_by == by:
		return

	if picked_up_by:
		let_go()

	picked_up_by = by
	original_transform = global_transform

	# now reparent it
	original_parent.remove_child(self)
	picked_up_by.add_child(self)

	# keep the original transform
	global_transform = original_transform

func let_go(impulse = Vector3(0.0, 0.0, 0.0)):
	if picked_up_by:
		# get our current global transform
		var t = global_transform

		# reparent it
		picked_up_by.remove_child(self)
		original_parent.add_child(self)

		# reposition it and apply impulse
		global_transform = t
		apply_impulse(Vector3(0.0, 0.0, 0.0), impulse)

		picked_up_by = null
