/**
 *	Politecnico di Milano
 *	IoT - Final Project
 *	Interfaces implementation
 */


#include "printf.h"
#include "Timer.h"
#include "KeepYourDistance.h"

/**
 * @author D'introno, Moreno, Zaniolo
 * @date   July 2020
 */

module KeepYourDistanceC @safe() {
    uses {

        interface AMSend; // Sender Component
        interface Receive; // Receiver Component

        interface Packet; // Message manipulator

        interface Boot;

        interface Timer < TMilli > as MilliTimer;
        interface SplitControl as AMControl; // Control interface   
        
    }
}
implementation {

    message_t packet;

    bool locked;
    
    /*
    	SEND
    */

    event void Boot.booted() {
        call AMControl.start();
    }

    event void AMControl.startDone(error_t err) {

        if (err == SUCCESS && TOS_NODE_ID > 0) {
            printf(
                "Mote: %d - Period: %d ms.\n",
                TOS_NODE_ID,
                TIMER_PERIOD_MILLI
            );
            call MilliTimer.startPeriodic(
                TIMER_PERIOD_MILLI
            );
        } else {
            call AMControl.start();
        }
    }

    event void AMControl.stopDone(error_t err) {
        // NOOP
    }

    event void MilliTimer.fired() {
        
        
        if (locked) {
            return;
        } else {
            /*
              Create and set message
            */
            kyd_msg_t * rcm = (kyd_msg_t * ) call Packet.getPayload( & packet, sizeof(kyd_msg_t));
            if (rcm == NULL) {
                return;
            }

            /*
            	Fill message
            */

            
            rcm-> near = TOS_NODE_ID;
            /*
			        Send message
    	      */
            if (call AMSend.send(AM_BROADCAST_ADDR, & packet, sizeof(kyd_msg_t)) == SUCCESS) {
                
                locked = TRUE;
            }
        }
    }

    event void AMSend.sendDone(message_t * bufPtr, error_t error) {
        if ( & packet == bufPtr) {
            locked = FALSE;
        }
    }

    /*
    	RECEIVE
    */

    event message_t * Receive.receive(message_t * bufPtr, void * payload, uint8_t len) {

        if (len != sizeof(kyd_msg_t)) {
            return bufPtr;
        } else {
            kyd_msg_t * rcm = (kyd_msg_t * ) payload;
            rcm-> src = TOS_NODE_ID;
            printf("{\"moteId_near\": %d,\"moteId_src\" : %d}\n", rcm-> near,rcm->src);

            return bufPtr;
        }
    }

}
