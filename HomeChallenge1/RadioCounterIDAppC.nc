/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Components relationship
*/
 
#include "RadioCounterID.h"

/**
	TODO Update this
 * Configuration for the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
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


