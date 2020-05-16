from scapy.contrib.coap import *
from scapy.contrib.mqtt import *

hw = rdpcap("homework3.pcap")

# Question 1
f1 = lambda r: CoAP in r and (r[CoAP].msg_id == 3978 or r[CoAP].msg_id == 22636)
my_print = lambda r: r[CoAP].show()

hw.nsummary(lfilter=f1, prn=my_print)

# Question 2


