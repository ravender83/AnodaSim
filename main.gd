extends Node2D

var topics = ["PLC", "TR_OUT", "A_OUT", "B_OUT", "C_OUT"]
var time_passed : float = 0.0
const TIME_INTERVAL : float = 0.2
var jazda = true
var inhibit = false
var speed = 0
var ramp = 0
var stop = 0

signal TR_speed
signal TR_ramp
signal TR_stop
signal TR
signal AX
signal AY
signal BX
signal BY

var boolean = {
	"false": false,
	"true": true
}

var TR_OUT = [0, 0, false]

var tagi = {
	"I25_2": {"on": false, "opis": "pozycja18"},
	"I25_1": {"on": false, "opis": "zwolnij18"},
	"I25_4": {"on": false, "opis": "zwolnij19"},
	"I25_3": {"on": false, "opis": "pozycja19"},
	"I201_0": {"on": false, "opis": "Aup"},
	"I201_1": {"on": false, "opis": "Adown"},
	"I203_7": {"on": false, "opis": "Azwolnijup"},
	"I203_6": {"on": false, "opis": "Azwolnijdown"},
	"I201_2": {"on": false, "opis": "Azawieszka"},
	#"I301_0": {"on": false, "opis": "Bup"},
	#"I301_1": {"on": false, "opis": "Bdown"},
	#"I303_7": {"on": false, "opis": "Bzwolnijup"},
	#"I303_6": {"on": false, "opis": "Bzwolnijdown"},
	#"I301_2": {"on": false, "opis": "Bzawieszka"},
}

func _visibility(_type):
	#if _type == 'show':
		#for i in $PLC.get_children():
			#i.show()
	#if _type == 'hide':
		#for i in $PLC.get_children():
			#i.hide()
	pass
			
func _update_hmi():
	for i in $PLC.get_children():		
		i.on = tagi[i.name].on
		i.tag = i.name.replace('_', '.')
		i.opis = tagi[i.name].opis
		i.update()
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	time_passed += delta	
	if time_passed >= TIME_INTERVAL:
		if $MQTT/labStatus.text == "connected":
			
			for key in tagi:
				_on_publish(get_node(str('%' + key)))
			$MQTT.publish('A_IN/AX_SPEED', str($Dzwigi/A/PlayerX.velocity.x), false, 0)
			$MQTT.publish('A_IN/AX_POSITION', str($Dzwigi/A/PlayerX.position.x), false, 0)
			$MQTT.publish('A_IN/AY_SPEED', str($Dzwigi/A/PlayerY.velocity.y), false, 0)
			
			#$MQTT.publish('B_IN/BX_SPEED', str($Dzwigi/B/PlayerX.velocity.x), false, 0)
			#$MQTT.publish('B_IN/BX_POSITION', str($Dzwigi/B/PlayerX.position.x), false, 0)
			#$MQTT.publish('B_IN/BY_SPEED', str($Dzwigi/B/PlayerX.velocity.y), false, 0)
		time_passed = 0.0


func _on_mqtt_broker_connected():
	$MQTT/labStatus.text = "connected"
	#_visibility('show')
	for i in topics:
		$MQTT.subscribe(i+'/+', 0)
	
func _on_mqtt_broker_disconnected():	
	$MQTT/labStatus.text = "disconnected"
	#_visibility('hide')

func _on_mqtt_broker_connection_failed():
	$MQTT/labStatus.text = "failed"

func _on_mqtt_received_message(topic, message):
	var top = topic.split('/')
	if top[0] in topics:
		if top[0] == "PLC":
			if tagi.has(top[1]):
				tagi[top[1]].on = boolean[message]
			else:
				print('Brak klucza: %s' % [top[1]])
			_update_hmi()
		if top[0] == "TR_OUT":
			var tmp = message.split('|')
			var send = false
			if int(tmp[0]) != TR_OUT[0]:
				TR_OUT[0] = int(tmp[0])
				send = true
			if int(tmp[1]) != TR_OUT[1]:
				TR_OUT[1] = int(tmp[1])
				send = true
			if boolean[tmp[2]] != TR_OUT[2]:
				TR_OUT[2] = boolean[tmp[2]]
				send = true				
			if send:
				emit_signal("TR", TR_OUT)
				send = false
				print('TR: ', message, ' ', TR_OUT)
				
			
			#if top[1] == "SPEED":
				#emit_signal("TR_speed", TR_OUT[0])
			#if top[1] == "RAMP":
				#emit_signal("TR_ramp", message)
			#if top[1] == "STOP":
				#emit_signal("TR_stop", boolean[message])
				
		if top[0] == "A_OUT":
			if top[1] == "A_JAZDA":
				jazda = boolean[message]
			if top[1] == "A_INHIBIT":
				inhibit = boolean[message]		
			if top[1] == "A_SPEED":
				speed = int(message)
			if top[1] == "A_RAMP":
				ramp = int(message)
			if top[1] == "A_STOP":
				stop = boolean[message]
			emit_signal("AX", jazda, inhibit, speed, ramp, stop)
			emit_signal("AY", jazda, inhibit, speed, ramp, stop)
					
		if top[0] == "B_OUT":
			if top[1] == "B_JAZDA":
				jazda = boolean[message]
			if top[1] == "B_INHIBIT":
				inhibit = boolean[message]		
			if top[1] == "B_SPEED":
				speed = int(message)
			if top[1] == "B_RAMP":
				ramp = int(message)
			if top[1] == "B_STOP":
				stop = boolean[message]

			#emit_signal("BX", jazda, inhibit, speed, ramp, stop)
			#emit_signal("BY", jazda, inhibit, speed, ramp, stop)			
	else:
		print("Nieznany topic: %s" % [top[0]])		
	pass
		
		
func _on_publish(obj):
	var qos = 0
	var topic = 'PLC/' + obj.name
	var message = str(obj.on)
	$MQTT.publish(topic, message, false, qos)		

func _on_btn_connect_toggled(button_pressed):
	if button_pressed:
		randomize()
		$MQTT.client_id = "s%d" % randi()
		$MQTT/labStatus.text = "connecting..."
		var broker = "tcp://127.0.0.1:1883"
		$MQTT.connect_to_broker(broker)
	else:
		$MQTT/labStatus.text = "disconnecting..."
		for i in topics:
			$MQTT.unsubscribe(i+'/+')
		$MQTT.disconnect_from_server()
