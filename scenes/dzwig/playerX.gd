extends CharacterBody2D


const speed = 300.0
const acc = 100
var collision

func _process(delta):
	$labPozycja.text = "X: %.1f" % position.x


func _physics_process(delta):
	var input = Vector2.ZERO
	if $"../PlayerY".velocity.y == 0 and not $"../PlayerY".collision:
		input = Vector2(Input.get_axis("ui_left", "ui_right"), 0).normalized() 
	
		if input.x != 0:
			velocity.x += input.x * acc * delta
			if abs(velocity.x) > speed:
				velocity.x = sign(velocity.x)*speed
		else:
			if abs(velocity.x) > 0:
				velocity.x -= sign(velocity.x) * acc * delta
				if abs(velocity.x) < 5:
					velocity.x = 0
	else:
		velocity.x = 0
		position.x = $"../PlayerY".position.x
		
	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = Vector2.ZERO
		var collider = collision.get_collider()
		#if collider is StaticBody2D:
		#	collider.move_and_collide(velocity * delta)


func _on_area_2d_body_entered(body):
	$Led.on = true


func _on_area_2d_body_exited(body):
	$Led.on = false
