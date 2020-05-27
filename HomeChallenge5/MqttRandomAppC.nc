/**
*	Politecnico di Milano
*	IoT - Home Challenge 5
*	Components relationship
*/
 
#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "MqttRandom.h"

/**
 * @author D'introno, Moreno, Zaniolo
 * @date   March 20 2020
 */

configuration MqttRandomAppC {}
implementation {
  components MainC, MqttRandomC as App, RandomC;
  components new AMSenderC(AM_RADIO_COUNT_MSG);
  components new AMReceiverC(AM_RADIO_COUNT_MSG);
  components new TimerMilliC();
  components ActiveMessageC;
  
  
  /*
	Serial print components
  */
  components SerialPrintfC;
  
  
  App.Boot -> MainC.Boot;
  
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.MilliTimer -> TimerMilliC;
  App.Packet -> AMSenderC;
  App.Random -> RandomC;
}


