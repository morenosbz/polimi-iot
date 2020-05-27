/**
*	Politecnico di Milano
*	IoT - Home Challenge 5
*	Interfaces implementation
*/
 
//TODO:
//#include <cstdlib>
#include "printf.h"
#include "Timer.h"
#include "MqttRandom.h"
 
/**
 * @author D'introno, Moreno, Zaniolo
 * @date   March 20 2020
 */

module MqttRandomC @safe() {
  uses {

  	interface AMSend; 		// Sender Component
    interface Receive;		// Receiver Component
    
  	interface Packet;		// Message manipulator
  	
    interface Boot;
    
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;	// Control interface    
  }
}
implementation {

  message_t packet;

  bool locked;
  //TODO:
  //uint16_t val = rand() % 100;
  uint16_t msgCounter = 88;
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
  		TIMER_PERIOD_MILLI
	);
	
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(
		TIMER_PERIOD_MILLI
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
	  mqtt_random_msg_t* rcm = (mqtt_random_msg_t*)call Packet.getPayload(&packet, sizeof(mqtt_random_msg_t));
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
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(mqtt_random_msg_t)) == SUCCESS) {
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
    if (len != sizeof(mqtt_random_msg_t)) {return bufPtr;}
    else {

      mqtt_random_msg_t* rcm = (mqtt_random_msg_t*)payload;
      printf("From MOTE %d -> Counter Received: %d\n", rcm->src, rcm->counter);

      printf("  >> MOD10 -> %d\n", rcm->counter%10);
      
      
      return bufPtr;
    }
  }

}




