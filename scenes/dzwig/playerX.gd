extends CharacterBody2D


var speed = 50.0
var acc = 200
var collision
var kierunek = 0
var stop = false


func _process(delta):
	$labPozycja.text = "X: %.1f" % position.x


func _physics_process(delta):
	var input = Vector2.ZERO
	if $"../PlayerY".velocity.y == 0 and not $"../PlayerY".collision:
		#input = Vector2(Input.get_axis("ui_left", "ui_right"), 0).normalized() 
		if stop:
			input.x = kierunek
		else:
			input.x = 0	
	
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

func _on_main_ax_speed(_speed):
	speed = floor(int(_speed) / 150)
	if speed < 0:
		kierunek = 1
	if speed == 0:
		kierunek = 0
	if speed > 0:
		kierunek = -1
	speed = abs(speed)


func _on_main_ax_ramp(_ramp):
	acc = abs(floor(int(_ramp) / 20))


func _on_main_ax_stop(_stop):
	stop = _stop

