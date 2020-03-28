/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 * @author D'introno, Moreno, Zaniolo
 * @date   March 28 2020
 */

#include "sendAck.h"
#include "Timer.h"

module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
    interface AMSend; 		// Sender Component
    interface Receive;		// Receiver Component
  	interface Packet;		// Message manipulator
    interface PacketAcknowledgements;
	//interface for timer
    interface Timer<TMilli> as MilliTimer;
    //other interfaces, if needed
    interface SplitControl;	// Control
    //interface FakeSensorC;
	
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t rec_id;
  message_t packet;
  bool locked;

  void sendReq();
  void sendRes();
  void sendResponse(double);
  
  
  //***************** Send request function ********************//
	void sendReq() {
		/* This function is called when we want to send a request
		*
		* STEPS:
		* 1. Prepare the msg
		* 2. Set the ACK flag for the message using the PacketAcknowledgements interface
		*     (read the docs)
		* 3. Send an UNICAST message to the correct node
		* X. Use debug statements showing what's happening (i.e. message fields)
		*/
		mote_req_t* req = (mote_req_t*)call Packet.getPayload(&packet, sizeof(mote_req_t));
		
		if(req == NULL){return;}
		req->counter = counter++;
		
		call PacketAcknowledgements.requestAck(&packet);
		//dbg("radio_send","BCADD %d\n", AM_BROADCAST_ADDR);
      	if (call AMSend.send(2, &packet, sizeof(mote_req_t)) == SUCCESS) {
		dbg("radio_send","C-%d :: REQUEST SENT\n", counter);	
		locked = TRUE;
      }
	}        

  //****************** Task send response *****************//
	void sendRes() {
		/* This function is called when we receive the REQ message.
		* Nothing to do here. 
		* `call Read.read()` reads from the fake sensor.
		* When the reading is done it raise the event read one.
		*/
		call Read.read();
	}
	
	void sendResponse(double meas){
		mote_res_t* res = (mote_res_t*)call Packet.getPayload(&packet, sizeof(mote_res_t));
	
		if(res == NULL){return;}
		res->counter = counter;
		res->meas = meas;
	
		call PacketAcknowledgements.requestAck(&packet);
	  	if (call AMSend.send(1, &packet, sizeof(mote_res_t)) == SUCCESS) {
			dbg("radio_send","C-%d :: RESPONSE SENT\n", counter);	
			locked = TRUE;
		}
	}

  //***************** Boot interface ********************//
	event void Boot.booted() {
		dbg("boot","MOTE%d booted.\n",TOS_NODE_ID);
		call SplitControl.start();
	}

  //***************** SplitControl interface ********************//
	event void SplitControl.startDone(error_t err){
		if (err == SUCCESS) {
			if(TOS_NODE_ID == 1){
				dbg(
					"boot",
					"Period MOTE%d OK\n",
					TOS_NODE_ID
					);
				call MilliTimer.startPeriodic(
					REQ_PERIOD
				);
			}
		}
		else {
			dbgerror(
				"radio",
				"radio error, restarting\n"
			);
			call SplitControl.start();
		}
	}
  
	event void SplitControl.stopDone(error_t err){
		// NOOP
	}

  //***************** MilliTimer interface ********************//
	event void MilliTimer.fired() {
		/* This event is triggered every time the timer fires.
		* When the timer fires, we send a request
		* Fill this part...
		*/
		dbg("init","=> Timer Fired (1S)\n");
		if (locked) {
			return;
		}
		sendReq();
	}
  

  //********************* AMSend interface ****************//
	event void AMSend.sendDone(message_t* buf,error_t err) {
		/* This event is triggered when a message is sent 
		*
		* STEPS:
		* 1. Check if the packet is sent
		* 2. Check if the ACK is received (read the docs)
		* 2a. If yes, stop the timer. The program is done
		* 2b. Otherwise, send again the request
		* X. Use debug statements showing what's happening (i.e. message fields)
		*/
		if(call PacketAcknowledgements.wasAcked(buf)){
			dbg("radio_ack","[√] Packet acknoledgment OK\n");
			if(call MilliTimer.isRunning()){
				call MilliTimer.stop();
				dbg("radio_ack","[√] Timer stopped\n");
			}
		}else{
			dbgerror("radio_ack","[x] Packet acknoledgment FAILED\n");
		}
		if (&packet == buf) {
		  locked = FALSE;
		}
	}

  //***************************** Receive interface *****************//
	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) {
		/* This event is triggered when a message is received 
		*
		* STEPS:
		* 1. Read the content of the message
		* 2. Check if the type is request (REQ)
		* 3. If a request is received, send the response
		* X. Use debug statements showing what's happening (i.e. message fields)
		*/
		dbg("radio_ack","***PACKET RECEIVED ");
	    if (len == sizeof(mote_req_t)){
	    	mote_req_t* req = (mote_req_t*)payload;
	    	dbg_clear("radio_ack","-> C-%d\n", req->counter);
	    	counter = req->counter;
			sendRes();
	    }
	    if (len == sizeof(mote_res_t)){
	    	mote_res_t* res = (mote_res_t*)payload;
	    	dbg_clear(
	    		"role"," -> C-%d => MEASUREMENT = %d\n",
	    		res->counter,
	    		res->meas
    		);
	    }	 
		
		return buf;
	}
  
  //************************* Read interface **********************//
	event void Read.readDone(error_t result, uint16_t data) {
		/* This event is triggered when the fake sensor finish to read (after a Read.read()) 
		*
		* STEPS:
		* 1. Prepare the response (RESP)
		* 2. Send back (with a unicast message) the response
		* X. Use debug statement showing what's happening (i.e. message fields)
		*/
		dbg("role","Measurement READ OK %d\n",data);
		sendResponse(data);
	}
}

