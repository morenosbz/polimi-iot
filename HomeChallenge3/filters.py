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
	my_print = lambda r: r.show()

	hw.nsummary(lfilter=f2, prn=my_print)
	
def question3():
	f3 = lambda r: CoAP in r and r[CoAP].code == 69 and r[IP].dst == "127.0.0.1"
	my_print = lambda r: "Message ID= "+ str(r[CoAP].msg_id)
	h1 = hw.filter(f3)
	h1.show(my_print)
	print "Total packets= " + str(len(h1))
	
question3()
