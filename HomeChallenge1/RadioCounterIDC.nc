/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Interfaces implementation
*/
 
#include "printf.h"
#include "Timer.h"
#include "RadioCounterID.h"
 
/**
	TODO Update this
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
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
  uint16_t counter = 0;
	
	/*
		SEND
	*/
  
  event void Boot.booted() {
    call AMControl.start();
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call MilliTimer.startPeriodic(250);
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void MilliTimer.fired() {
    printf("Ciao raga!");
  	printfflush();
    counter++;
    dbg("RadioCounterIDC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
    if (locked) {
      return;
    }
    else {
    	/*
    	TODO Create and set message
    	*/
	  radio_count_msg_t* rcm = (radio_count_msg_t*)call Packet.getPayload(&packet, sizeof(radio_count_msg_t));
      if (rcm == NULL) {
		return;
      }

      rcm->counter = counter;
      /*
      	Send message
      */
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("RadioCounterIDC", "RadioCountToLedsC: packet sent.\n", counter);	
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
    dbg("RadioCounterIDC", "Received packet of length %hhu.\n", len);
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;
      if (rcm->counter & 0x1) {
		call Leds.led0On();
      }
      else {
		call Leds.led0Off();
      }
      if (rcm->counter & 0x2) {
		call Leds.led1On();
      }
      else {
		call Leds.led1Off();
      }
      if (rcm->counter & 0x4) {
		call Leds.led2On();
      }
      else {
		call Leds.led2Off();
      }
      return bufPtr;
    }
  }

}




