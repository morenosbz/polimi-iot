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
  components new TimerMilliC() as Timer0; //new
  components new TimerMilliC() as Timer1;//new
  components new TimerMilliC() as Timer2; //new
  components ActiveMessageC;
  
  /*
	Serial print components
  */
  components SerialPrintfC;
  
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.Leds -> LedsC;
  App.Timer0 -> Timer0; //new
  App.Timer1 -> Timer1; //new
  App.Timer2 -> Timer2; //new
  App.Packet -> AMSenderC;
}


