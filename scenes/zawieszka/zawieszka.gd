extends CharacterBody2D


var collision
var grabbed = false
var vel: Vector2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 10


func _physics_process(delta):
	if grabbed == true:
		velocity = vel
	else:
		if not is_on_floor():
			velocity.x = 0
			velocity.y += gravity
	collision = move_and_slide()
