// $Id: RadioCountToLedsC.nc,v 1.7 2010-06-29 22:07:17 scipio Exp $

/*									tab:4
 * Copyright (c) 2000-2005 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the University of California nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Copyright (c) 2002-2003 Intel Corporation
 * All rights reserved.
 *
 * This file is distributed under the terms in the attached INTEL-LICENSE     
 * file. If you do not find these files, copies can be found by writing to
 * Intel Research Berkeley, 2150 Shattuck Avenue, Suite 1300, Berkeley, CA, 
 * 94704.  Attention:  Intel License Inquiry.
 */
 
#include "Timer.h"
#include "Network.h"
#include "printf.h"
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module NetworkC @safe() {
  uses {
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
    interface Random;
  }
}
implementation {

  message_t packet,packet2;

 
  uint16_t random2 = 0;
  uint16_t random3 = 0;
  
  event void Boot.booted() {
    printf( "Mote: %d\n", TOS_NODE_ID);
    printfflush();
    call AMControl.start();
  }


  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) { 
    		call MilliTimer.startPeriodic(5000);	
    	
    	
      
      
    }
    else {
      call AMControl.start();
    }
  }

  event void AMControl.stopDone(error_t err) {
    // do nothing
  }
  
  event void MilliTimer.fired() {
    radio_msg_t* rcm = (radio_msg_t*)call Packet.getPayload(&packet, sizeof(radio_msg_t));
    radio_msg_t* rcm2 = (radio_msg_t*)call Packet.getPayload(&packet2, sizeof(radio_msg_t));
  	random2= call Random.rand16()%101;  
  	random3=call Random.rand16()%101;
    dbg("Network", "RadioCountToLedsC: timer fired, random number generated is %hu.\n", random2);
    
      
      if (rcm == NULL || rcm2==NULL) {
	return;
      }

      rcm->random = random2;
      rcm->topic = 2;
      rcm2->random = random3;
      rcm2->topic = 3;
      if(TOS_NODE_ID==2){
      if (call AMSend.send(1, &packet, sizeof(radio_msg_t)) == SUCCESS) {
	dbg("NetworkC", "NetworkC: random number sent. from %d\n", random2,TOS_NODE_ID);	
      }
      }
      if(TOS_NODE_ID==3){
      if (call AMSend.send(1, &packet2, sizeof(radio_msg_t)) == SUCCESS) {
	dbg("NetworkC", "NetworkC: random number sent. from %d\n", random3,TOS_NODE_ID);	
      }
      }
    
  }
  

  event message_t* Receive.receive(message_t* bufPtr, void* payload, uint8_t len) {
    dbg("NetworkC", "Received random number %hhu.\n", );
    if (len != sizeof(radio_msg_t)) {return bufPtr;}
    else {
      radio_msg_t* rcm = (radio_msg_t*)payload;
      printf(" {\"number\":%u,\"topic\":%u}\n ",rcm->random,rcm->topic);
      
      return bufPtr;
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    if (&packet == bufPtr) {
    }
  }

}




