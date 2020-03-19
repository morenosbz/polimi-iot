/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Interfaces implementation
*/
 
#include "printf.h"
#include "Timer.h"
#include "RadioCounterID.h"
#include "utils.c"
 
/**
 * Implementation of the RadioCounterID application. RadioCounterID 
 * depending on the Mote id, the frequency is setted, 1Hz, 3Hz or 5Hz.
 * Then a broadcast message is sent, with the source and the actual count.
 * As a receiver, the mote identifies the source, toggle the corresponding LED
 * and if the count is modulus 10, all the leds are turned off.
 *
 * @author D'introno, Moreno, Zaniolo
 * @date   March 20 2020
 */

module RadioCounterIDC @safe() {
  uses {

  	interface AMSend; 		// Sender Component
    interface Receive;		// Receiver Component
    
  	interface Packet;		// Message manipulator
  	
    interface Leds;
    interface Boot;
    
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;	// Control interface    
  }
}
implementation {

  message_t packet;

  bool locked;
  uint16_t msgCounter = 0;
	/*
		SEND
	*/
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
  	printf(
  		"Mote: %d - Period: %d ms.\n",
  		TOS_NODE_ID,
  		getPeriodFromID(TOS_NODE_ID)
	);
	
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(
		getPeriodFromID(TOS_NODE_ID)
      );
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
    
  event void MilliTimer.fired() {
    printf("Timer fired -> counter: %d.\n", msgCounter);
    if (locked) {
      return;
    }
    else {
    	/*
			Create and set message
    	*/
	  id_count_msg_t* rcm = (id_count_msg_t*)call Packet.getPayload(&packet, sizeof(id_count_msg_t));
      if (rcm == NULL) {
		return;
      }

		/*
			Fill message
		*/
		
      rcm->counter = msgCounter;
      rcm->src = TOS_NODE_ID;
	    /*
			Send message
    	*/
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(id_count_msg_t)) == SUCCESS) {
		printf("MSG SENT: %d\n", msgCounter);	
		locked = TRUE;
      }
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
      locked = FALSE;
    }
  }
  
  	/*
  		RECEIVE
  	*/
  
  
  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
  	/*
  	FIXME counter should be a count of any message or only succesfully ones?
	Update counter for each message received
	*/
      msgCounter++;
    printf("Received packet of length %d.\n", len);
    if (len != sizeof(id_count_msg_t)) {return bufPtr;}
    else {

      id_count_msg_t* rcm = (id_count_msg_t*)payload;
      printf("From MOTE %d -> Counter Received: %d\n", rcm->src, rcm->counter);

      printf("  >> MOD10 -> %d\n", rcm->counter%10);
      if(rcm->counter % 10 == 0){
      	printf("    >> MOD10 -> TURNOFF NOW\n");
		call Leds.led0Off();      	
		call Leds.led1Off();
		call Leds.led2Off();
      } else {
		  if(rcm->src == 1){
	  	    call Leds.led0Toggle();
		  }
		  if(rcm->src == 2){
	  	    call Leds.led1Toggle();
		  }
		  if(rcm->src == 3){
	  	    call Leds.led2Toggle();
		  }
      }
      
      return bufPtr;
    }
  }

}




