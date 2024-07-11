extends CharacterBody2D	

var speed = 6.0
var acc = 100
var collision
var kierunek = 0
var stop = false

func _process(delta):
	$labPozycja.text = "Y: %.1f" % position.y
	
func _physics_process(delta):
	var input = Vector2.ZERO
	if $"../PlayerX".velocity.x == 0  and not $"../PlayerX".collision:
		#input = Vector2(0, Input.get_axis("ui_up", "ui_down")).normalized() 
		if stop:
			input.y = kierunek
		else:
			input.y = 0	
			
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


func _on_main_ay_speed(_speed):
	speed = floor(int(_speed) / 2000)
	if speed < 0:
		kierunek = 1
	if speed == 0:
		kierunek = 0
	if speed > 0:
		kierunek = -1
	speed = abs(speed)


func _on_main_ay_ramp(_ramp):
	acc = abs(floor(int(_ramp) / 10))


func _on_main_ay_stop(_stop):
	stop = _stop
