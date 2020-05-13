import sys
from scapy.all import *


def method_filter_HTTP(pkt):
    print pkt
    # Your processing


a = rdpcap("homework3.pcap")
sniff(offline="homework3.pcap", prn=method_filter_HTTP, store=0)
