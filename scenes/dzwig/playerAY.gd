extends CharacterBody2D	

var speed = 6.0
var acc = 100
var collision
var kierunek = 0
var stop = false
var enable = false

func _process(delta):
	$labPozycja.text = "Y: %.1f" % position.y
	
	
func zaokraglij_pozycje(aktualna_pozycja):
	# Lista docelowych pozycji od 0 do 1700 z krokiem 100
	var docelowe_pozycje = []
	for i in range(0, 1800, 100):
		docelowe_pozycje.append(i)
		
	for docelowa in docelowe_pozycje:
		if abs(aktualna_pozycja - docelowa) <= 5:
			return docelowa
	return (aktualna_pozycja)
	
		
func _physics_process(delta):
	var input = Vector2.ZERO
	if $"../PlayerX".velocity.x == 0  and not $"../PlayerX".collision:
		#input = Vector2(0, Input.get_axis("ui_up", "ui_down")).normalized() 
		if stop:
			input.y = kierunek
		else:
			input.y = 0
			position.x = zaokraglij_pozycje(position.x)	
			
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


func _on_main_ay(_jazda, _inhibit, _speed, _ramp, _stop):
	if _jazda:
		enable = true
		acc = abs(floor(_ramp / 10))
		stop = _stop or _inhibit
		if stop:
			speed = floor(_speed / 1500)
			if speed < 0:
				kierunek = 1
			if speed == 0:
				kierunek = 0
			if speed > 0:
				kierunek = -1
			speed = abs(speed)
		else:
			speed = 0.0
			velocity.y = 0
		
	else:
		enable = false
		stop = false
		speed = 0.0
		velocity.y = 0
