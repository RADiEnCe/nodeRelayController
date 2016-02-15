import paho.mqtt.client as mqclient

def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))
    client.subscribe("#")

def on_message(client, userdata, msg):
    print(msg.topic + " " + str(msg.payload))

client = mqclient.Client()
client.username_pw_set(username = "dcnyksxj", password = "4iilwrHUMzLm")
client.on_connect = on_connect
client.on_message = on_message

client.connect("m10.cloudmqtt.com", 17440)

client.publish("node1/jset", '{"a":1,"d":1,"c":0,"b":0}')
