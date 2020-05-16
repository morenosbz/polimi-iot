#import scapy.all
#from scapy.contrib.coap import *
#from scapy.contrib.mqtt import *

import os
print os.sys.path
os.sys.path.append('/usr/local/lib/python2.7/dist-packages')
print os.sys.path

def method_filter_HTTP(pkt):
    print(pkt)
    # Your processing


# hw = rdpcap("homework3.pcap")


