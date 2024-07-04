extends Node2D

var topics = ["PLC"]
var time_passed : float = 0.0
const TIME_INTERVAL : float = 0.5

var boolean = {
	"false": false,
	"true": true
}

var tagi = {
	"I25_2": {"on": false, "opis": "Siłownik HP"},
	"I25_1": {"on": false, "opis": "Siłownik WP"},
	"I25_4": {"on": false, "opis": "Siłownik EZ HP"},
	"I25_3": {"on": false, "opis": "Siłownik EZ WP"},
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
			_on_publish(%I25_2)
			pass
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
	else:
		print("Nieznany topic: %s" % [top[0]])		
		
		
func _on_publish(obj):
	var qos = 0
	print(obj)
	var topic = 'PLC/' + obj.name
	var message = str(obj.on)
	#$MQTT.publish(topic, message, false, qos)		

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
