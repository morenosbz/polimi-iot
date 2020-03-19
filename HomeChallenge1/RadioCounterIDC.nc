/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Interfaces implementation
*/
 
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
    call Timer0.startPeriodic( 1000 );		//timer0 1Hz->mote1
    call Timer1.startPeriodic( 333 );		//timer1 3Hz->mote2
    call Timer2.startPeriodic( 200 );		//timer2 5Hz->mote3
  }

  event void AMControl.startDone(error_t err) {		//start RADIO
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
  





  event void Timer0.fired() {			//new
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
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
      rcm->senderID = TOS_NODE_ID;	//check
      /*
      	Send message
      */
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("RadioCountToLedsC", "RadioCountToLedsC: packet sent.\n", counter);	
		locked = TRUE;
      }
    }
  }


 event void Timer1.fired() {			//new
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
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
      rcm->sendID = TOS_NODE_ID;
      
      /*
      	Send message
      */
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("RadioCountToLedsC", "RadioCountToLedsC: packet sent.\n", counter);	
		locked = TRUE;
      }
    }
  }


 event void Timer2.fired() {			//new
    counter++;
    dbg("RadioCountToLedsC", "RadioCountToLedsC: timer fired, counter is %hu.\n", counter);
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
      rcm->sendID=TOS_NODE_ID;
      /*
      	Send message
      */
      if (call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(radio_count_msg_t)) == SUCCESS) {
		dbg("RadioCountToLedsC", "RadioCountToLedsC: packet sent.\n", counter);	
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
    dbg("RadioCountToLedsC", "Received packet of length %hhu.\n", len);
    if (len != sizeof(radio_count_msg_t)) {return bufPtr;}
    else {
      radio_count_msg_t* rcm = (radio_count_msg_t*)payload;
      if (rcm->sendID == 1) {			// se il messaggio proviene da mote1->toggle led0
		call Leds.led0Toggle();		// se il messaggio proviene da mote2->toggle led1
      }						// se il messaggio proviene da mote3->toggle led2
      						// se il messaggio contiene count % 10==0->turn off
      if (rcm->sendID == 2) {
		call Leds.led1Toggle();
      }
      if (rcm->sendID == 3) {
		call Leds.led2Toggle();
      }
      if (rcm->count % 10 == 0) {
		call Leds.led0Off();
		call Leds.led1Off();
		call Leds.led2Off();
      }
      return bufPtr;
    }
  }

}




