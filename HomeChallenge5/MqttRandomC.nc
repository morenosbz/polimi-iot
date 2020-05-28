/**
 *	Politecnico di Milano
 *	IoT - Home Challenge 5
 *	Interfaces implementation
 */


#include "printf.h"
#include "Timer.h"
#include "MqttRandom.h"

/**
 * @author D'introno, Moreno, Zaniolo
 * @date   May 2020
 */

module MqttRandomC @safe() {
    uses {

        interface AMSend; // Sender Component
        interface Receive; // Receiver Component

        interface Packet; // Message manipulator

        interface Boot;

        interface Timer < TMilli > as MilliTimer;
        interface SplitControl as AMControl; // Control interface   
        interface Random;
    }
}
implementation {

    message_t packet;

    bool locked;
    //uint16_t val = rand() % 100;
    uint16_t val = 88;
    /*
    	SEND
    */

    event void Boot.booted() {
        call AMControl.start();
    }

    event void AMControl.startDone(error_t err) {

        if (err == SUCCESS && TOS_NODE_ID > 1) {
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
        val = call Random.rand16() % 101;
        printf("Timer fired -> val: %d.\n", val);
        if (locked) {
            return;
        } else {
            /*
              Create and set message
            */
            mqtt_random_msg_t * rcm = (mqtt_random_msg_t * ) call Packet.getPayload( & packet, sizeof(mqtt_random_msg_t));
            if (rcm == NULL) {
                return;
            }

            /*
            	Fill message
            */

            rcm - > counter = val;
            rcm - > src = TOS_NODE_ID;
            /*
			        Send message
    	      */
            if (call AMSend.send(1, & packet, sizeof(mqtt_random_msg_t)) == SUCCESS) {
                printf("MSG SENT: %d\n", val);
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
        //printf("Received packet of length %d.\n", len);
        if (len != sizeof(mqtt_random_msg_t)) {
            return bufPtr;
        } else {
            mqtt_random_msg_t * rcm = (mqtt_random_msg_t * ) payload;
            printf("{\"moteId\": %d, \"value\": %d}\n", rcm - > src, rcm - > counter);

            return bufPtr;
        }
    }

}