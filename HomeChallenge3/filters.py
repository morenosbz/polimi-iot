from scapy.contrib.coap import *
from scapy.contrib.mqtt import *

hw = rdpcap("homework3.pcap")

COAP_CONTENT = 69
LOCALHOST = "127.0.0.1"

MQTT_TYPE_CONNECT = 1
MQTT_TYPE_CONNACK = 2
MQTT_TYPE_PUBLISH = 3
MQTT_TYPE_PUBACK = 4

MQTT_WILLFLAG_ENABLE = 1

# Question 1
def question1():
	f1 = lambda r: CoAP in r and (r[CoAP].msg_id == 3978 or r[CoAP].msg_id == 22636)
	my_print = lambda r: r[CoAP].show()

	hw.nsummary(lfilter=f1, prn=my_print)

# Question 2
def question2():
	msgToken = hw[6948][CoAP].token
	print "Packet No. 6949 token " + msgToken
	f2 = lambda r: CoAP in r and r[CoAP].token == msgToken
	print "Packets with the same token"
	my_print = lambda r: "Packet IP.id= "+ str(r[IP].id)

	hw.nsummary(lfilter=f2, prn=my_print)
	
def question3():
	f3 = lambda r: CoAP in r and r[CoAP].code == COAP_CONTENT and r[IP].dst == LOCALHOST
	my_print = lambda r: "Message ID= "+ str(r[CoAP].msg_id)
	#my_print = lambda r: r[CoAP].show()
	h1 = hw.filter(f3)
	h1.show(my_print)
	print "Total packets= " + str(len(h1))
	
def question4():
		
	f41 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_CONNECT and r[MQTT].username == "jane"
	connect_pkts = hw.filter(f41)
	#connect_seq = map(my_print, connect_pkts)
	print "Connections with username = jane"
	conn_print = lambda r: r[IP].src + ':' + str(r[TCP].sport)
	connect_pkts.show(conn_print)
	connect_ports = map(lambda r: r[TCP].sport, connect_pkts)
	
	f42 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_PUBLISH and "factory/department" in r[MQTT].topic
	topic_pkts = hw.filter(f42)
	print "Packets with the factory/department topic = " + str(len(topic_pkts))
	
	f43 = lambda r: r[TCP].sport in connect_ports
	jane_publish = topic_pkts.filter(f43)
	print "Published messages from jane"
	my_print = lambda r: "Packet IP.id= "+ str(r[IP].id)
	jane_publish.show(my_print)
	print "Total packets from a connection with username eq jane = " + str(len(jane_publish))
	
def question5():
	f51 = lambda r: DNSRR in r and "broker.hivemq.com" in r[DNSRR].rrname 
	hivemq_pkts = hw.filter(f51)
	hivemq_ip = set(map(lambda r: r[DNSRR].rdata, hivemq_pkts))
	print "IPs of the broker broker.hivemq.com"
	print hivemq_ip
	
	f52 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_CONNECT
	conn_pkts = hw.filter(f52)
	#and "willflag" in r[MQTT]
	print "Connection packets total = " + str(len(conn_pkts))
	
	f53 = lambda r: r[MQTT].willflag == MQTT_WILLFLAG_ENABLE
	will_pkts = conn_pkts.filter(f53)
	print "Connection packets with willFlag = " + str(len(will_pkts))
	
	f54 = lambda r: r[IP].dst in hivemq_ip
	res = will_pkts.filter(f54)
	print "Connection packets with willFlag connected to hivemq = " + str(len(res))
	
	# FIXME: Find a proper way to define raw error
	f55 = lambda r: not MQTT in r[MQTT][MQTTConnect]
	response = res.filter(f55)
	print "Connection packets with willFlag connected to hivemq without errors = " + str(len(response))	
	
def question6():
	f61 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_PUBLISH and r[MQTT].QOS == 1
	pub_pkts = hw.filter(f61)
	print "Publish packets QOS1 total = " + str(len(pub_pkts))
	pub_ids = set(map(lambda r: r[MQTT].msgid, pub_pkts))
	print "Messages' ID to publish"
	print pub_ids
	
	f62 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_PUBACK
	puback_pkts = hw.filter(f62)
	print "Ackowledged publish packets total = " + str(len(puback_pkts))
	
	f63 = lambda r: not MQTT in r[MQTT][MQTTPuback]
	puback_ef_pkts = puback_pkts.filter(f63)
	print "Ackowledged publish packets without errors = " + str(len(puback_ef_pkts))
	ack_ids = set(map(lambda r: r[MQTT].msgid, puback_ef_pkts))
	print "Messages' ID acknowledged"
	print ack_ids
	
	notack_ids = pub_ids - ack_ids
	f64 = lambda r: r[MQTT].msgid in notack_ids
	res1 = pub_pkts.filter(f64)
	print "Published messages id without ack = " + str(len(res1))
	
def question7():	
	f71 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_CONNECT
	conn_pkts = hw.filter(f71)
	error_msgs = set(map(lambda r: r[MQTT].willmsg,conn_pkts))
	#conn_pkts.show(my_print)
	print "Error messages total = " + str(len(error_msgs))
	
	f72 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_PUBLISH and r[MQTT].QOS == 0
	pub_qos0_pkts = hw.filter(f72)
	print "Publish packets QOS0 total = " + str(len(pub_qos0_pkts))
	
	f73 = lambda r: r[MQTT].value in error_msgs
	last_pkts = pub_qos0_pkts.filter(f73)
	print "Publish packets QOS0 with a LastWill Message = " + str(len(last_pkts))
	
def question9():
	f91 = lambda r: MQTT in r and r[MQTT].type == MQTT_TYPE_CONNECT
	conn_pkts = hw.filter(f91)
	
	f92 = lambda r: r[MQTT].protolevel == 5
	conn_v5_pkts = conn_pkts.filter(f92)
	conn_v5_len = map(lambda r: len(r), conn_v5_pkts)
	avg = sum(conn_v5_len)/len(conn_v5_len)
	print "Packet average " + str(avg)
	
question9()






