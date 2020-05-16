from scapy.contrib.coap import *
from scapy.contrib.mqtt import *

hw = rdpcap("homework3.pcap")

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
	f3 = lambda r: CoAP in r and r[CoAP].code == 69 and r[IP].dst == "127.0.0.1"
	my_print = lambda r: "Message ID= "+ str(r[CoAP].msg_id)
	#my_print = lambda r: r[CoAP].show()
	h1 = hw.filter(f3)
	h1.show(my_print)
	print "Total packets= " + str(len(h1))
	
def question4():
		
	f41 = lambda r: MQTT in r and r[MQTT].type == 1 and r[MQTT].username == "jane"
	connect_pkts = hw.filter(f41)
	#connect_seq = map(my_print, connect_pkts)
	print "Connections with username = jane"
	conn_print = lambda r: r[IP].src + ':' + str(r[TCP].sport)
	connect_pkts.show(conn_print)
	connect_ports = map(lambda r: r[TCP].sport, connect_pkts)
	
	f42 = lambda r: MQTT in r and r[MQTT].type == 3 and "factory/department" in r[MQTT].topic
	topic_pkts = hw.filter(f42)
	print "Packets with the factory/department topic = " + str(len(topic_pkts))
	
	f43 = lambda r: r[TCP].sport in connect_ports
	jane_publish = topic_pkts.filter(f43)
	print "Published messages from jane"
	my_print = lambda r: "Packet IP.id= "+ str(r[IP].id)
	jane_publish.show(my_print)
	print "Total packets from a connection with username eq jane = " + str(len(jane_publish))
	
def question5():
	f5 = lambda r: DNS in r
	my_print = lambda r: r[DNS].show()
	hw.nsummary(lfilter=f5, prn=my_print)
		
question5()






