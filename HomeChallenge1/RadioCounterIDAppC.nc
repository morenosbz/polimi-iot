/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Components relationship
*/
 
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "RadioCounterID.h"

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

configuration RadioCounterIDAppC {}
implementation {
  components MainC, RadioCounterIDC as App, LedsC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new TimerMilliC();
  components ActiveMessageC;
  
  /*
	Serial print components
  */
  components PrintfC;
  components SerialStartC;
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AMSenderC;
}


