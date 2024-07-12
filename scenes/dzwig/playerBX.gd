extends CharacterBody2D


var speed = 50.0
var acc = 200
var collision
var kierunek = 0
var stop = false
var enable = false

func zaokraglij_pozycje(aktualna_pozycja):
	# Lista docelowych pozycji od 0 do 1700 z krokiem 100
	var docelowe_pozycje = []
	for i in range(0, 1800, 100):
		docelowe_pozycje.append(i)
		
	for docelowa in docelowe_pozycje:
		if abs(aktualna_pozycja - docelowa) <= 5:
			return docelowa
	return (aktualna_pozycja)
	

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
			position.x = zaokraglij_pozycje(position.x)
	
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

func _on_main_bx(_jazda, _inhibit, _speed, _ramp, _stop):
	if not _jazda:
		enable = true
		acc = abs(floor(_ramp / 20))
		stop = _stop or _inhibit
		if stop:
			speed = floor(_speed / 150)
			if speed < 0:
				kierunek = 1
			if speed == 0:
				kierunek = 0
			if speed > 0:
				kierunek = -1
			speed = abs(speed)
		else:
			speed = 0.0
			velocity.x = 0
		
	else:
		enable = false
		stop = false
		speed = 0.0
		velocity.x = 0
