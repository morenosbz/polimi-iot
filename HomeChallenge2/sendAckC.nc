/**
 *  Source file for implementation of module sendAckC in which
 *  the node 1 send a request to node 2 until it receives a response.
 *  The reply message contains a reading from the Fake Sensor.
 *
 *  @author D'introno, Moreno, Zaniolo
 */

#include "sendAck.h"
#include "Timer.h"


module sendAckC {

  uses {
  /****** INTERFACES *****/
	interface Boot; 
	
    //interfaces for communication
    
    interface AMSend;		//Send
    interface Receive;		//Receive
    interface SplitControl;	//Radio
	//interface for timer
	interface Timer<TMilli> as MilliTimer;
    //other interfaces, if needed
	interface Packet;
	interface PacketAcknowledgements as ack;
	//interface used to perform sensor reading (to get the value from a sensor)
	interface Read<uint16_t>;
  }

} implementation {

  uint8_t counter=0;
  uint8_t rec_id;			
  message_t packet;
  

  void sendReq();
  void sendResp();
  
  
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
//1.	 
	 my_msg_t* message = (my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t)));
	  if (message == NULL) {
		return;
	   }
	 message->msg_type=REQ;
	 message->msg_counter=++counter;
	 dbg("radio_pack","Preparing the message... \n");
	 dbg("counter","packet n. %u\n",message->msg_counter);
//2.	 
	 call ack.requestAck(&packet);
//3.
	 if(call AMSend.send(2, &packet,sizeof(my_msg_t)) == SUCCESS){		//unicast packet to mote#2
	     dbg("radio_send", "Packet passed to lower layer successfully!\n");
	     dbg_clear("radio_pack","\t Payload Sent\n" );
		 dbg_clear("radio_pack", "\t\t type: %hhu \n ", message->msg_type);
		 }
 }        

  //****************** Task send response *****************//
  void sendResp() {
  	/* This function is called when we receive the REQ message.
  	 * Nothing to do here. 
  	 * `call Read.read()` reads from the fake sensor.
  	 * When the reading is done it raise the event read one.
  	 */
	call Read.read();
  }

  //***************** Boot interface ********************//
  event void Boot.booted() {
	dbg("boot","Application booted.\n");
	/* Fill it ... */
	call SplitControl.start();		//startRadio
  }

  //***************** SplitControl interface ********************//
  event void SplitControl.startDone(error_t err){
    /* Fill it ... */
    if(err == SUCCESS) {
    	dbg("radio", "Radio on!\n");
    	if(TOS_NODE_ID == 1){
    	//periodic Request 
    		call MilliTimer.startPeriodic( 1000 );	
    	}
        
    }
    else{
	//dbg for error
	dbgerror("radio_err","radio error, restart radio\n");
	call SplitControl.start();
    }
  }
  
  event void SplitControl.stopDone(error_t err){
    
    //empty event 
  }

  //***************** MilliTimer interface ********************//
  event void MilliTimer.fired() {
	/* This event is triggered every time the timer fires.
	 * When the timer fires, we send a request
	 * Fill this part...
	 */
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
//1.
	if (&packet == buf && err == SUCCESS) {
      dbg("radio_send", "Packet sent...");
      dbg_clear("radio_send", " at time %s \n", sim_time_string());
    }
    else{
      dbgerror("radio_send", "Send done error!");
    }
//2.
    if(call ack.wasAcked(buf)== TRUE){
//2a.
    	call MilliTimer.stop();
    	dbg("radio_ack","  [√] Packet acknoledgment OK\n");
    }
   else{
//2b.
			dbgerror("radio_ack","  [x] Packet acknoledgment FAILED\n");
			dbgerror("radio_ack","  Sending again...\n");
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
 //1.
	 my_msg_t* message = (my_msg_t*)payload;
	 counter=message->msg_counter;
 //2. and 3.
	  if(message->msg_type==REQ){
	 		sendResp();
	 	}
	  dbg("radio_rec", "Received packet at time %s\n", sim_time_string());
      dbg("radio_pack", ">>>Pack \n");
      dbg_clear("radio_pack","\t\t Payload Received\n" );
      dbg_clear("radio_pack", "\t\t type: %hhu \n ", message->msg_type);
      dbg_clear("radio_pack", "\t\t data: %hhu \n", message->value);
     
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
	 
  //1.
     my_msg_t* resp=(my_msg_t*)(call Packet.getPayload(&packet, sizeof(my_msg_t))); 
     resp->msg_type=RESP;
	 resp->msg_counter=counter;
     resp->value=data;
     dbg("read","Measurement READ OK\n");
  //2.
     call ack.requestAck(&packet);
	 if(call AMSend.send(1, &packet,sizeof(my_msg_t)) == SUCCESS){		//unicast packet to mote#1
	     dbg("radio_send", "Packet passed to lower layer successfully!\n");
	     dbg_clear("radio_pack","\t Payload Sent\n" );
		 dbg_clear("radio_pack", "\t\t type: %hhu \n ", resp->msg_type);
		 }

	}
}

