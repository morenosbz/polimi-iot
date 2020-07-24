import requests

TSW_API_KEY = "LS6GQ5O5WWAD2FPY"
TSW_CHANNEL_ID = "1063988"
TSR_API_KEY = "UY3PX2BIF272W0K9"

TS_HOST = "http://api.thingspeak.com"

HTTP_APIKEY = "?api_key="
HTTP_FIELD1 = "&field1="

UPDATE = "/update"
DELETE = "/delete"


def create_update_req(new_val):
	return TS_HOST + UPDATE + HTTP_APIKEY + TSW_API_KEY + HTTP_FIELD1 + str(new_val)
	
def create_read_req():
	return TS_HOST + "channels/"+TSW_CHANNEL_ID+"/fields/1.json?results=0"
	
def create_delete_req():
	return TS_HOST + DELETE + HTTP_APIKEY + TSW_API_KEY

#delete_request = TS_HOST + "/delete?api_key="+TSW_API_KEY
#update_request = TS_HOST + "/update?api_key="+TSW_API_KEY

# FIXME: The only that it's actually working
r = requests.get(create_update_req(2.2))
#r = requests.get(create_read_req())

#print(r.json())
