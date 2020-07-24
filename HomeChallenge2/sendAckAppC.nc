/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 *   @author D'introno, Moreno, Zaniolo
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {


/****** COMPONENTS *****/
  components MainC, sendAckC as App;
  //add the other components here
  components ActiveMessageC;
  components new AMSenderC(AM_MY_MSG);
  components new AMReceiverC(AM_MY_MSG);
  //components  PacketAcknowledgements;
  //timer
  components new TimerMilliC() as timer;
  components new FakeSensorC();

/****** INTERFACES *****/
  //Boot interface
  App.Boot -> MainC.Boot;

  /****** Wire the other interfaces down here *****/
  //Send and Receive interfaces
  App.Receive -> AMReceiverC;
  App.AMSend -> AMSenderC;
  
  //Radio Control
  App.SplitControl -> ActiveMessageC;
  //Interfaces to access package fields
  App.Packet -> AMSenderC;
  App.ack->AMSenderC;
  //Timer interface
  App.MilliTimer -> timer;
  //Fake Sensor read
  App.Read -> FakeSensorC;

}

