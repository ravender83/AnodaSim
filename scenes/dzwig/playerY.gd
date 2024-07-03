extends CharacterBody2D	

const speed = 300.0
const acc = 100
var collision

func _process(delta):
	$labPozycja.text = "Y: %.1f" % position.y
	
func _physics_process(delta):
	var input = Vector2.ZERO
	if $"../PlayerX".velocity.x == 0  and not $"../PlayerX".collision:
		input = Vector2(0, Input.get_axis("ui_up", "ui_down")).normalized() 
	
		if input.y != 0:
			velocity.y += input.y * acc * delta
			if abs(velocity.y) > speed:
				velocity.y = sign(velocity.y)*speed
		else:
			if abs(velocity.y) > 0:
				velocity.y -= sign(velocity.y) * acc * delta
				if abs(velocity.y) < 5:
					velocity.y = 0
	else:
		velocity.x = 0
		position.x = $"../PlayerX".position.x
	velocity.x = $"../PlayerX".velocity.x

	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2.ZERO
		var collider = collision.get_collider()
		#if collider is CharacterBody2D:
			#collider.move_and_collide(velocity * delta)
