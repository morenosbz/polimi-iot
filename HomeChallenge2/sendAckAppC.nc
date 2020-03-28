/**
 *  Configuration file for wiring of sendAckC module to other common 
 *  components needed for proper functioning
 *
 * @author D'introno, Moreno, Zaniolo
 * @date   March 28 2020
 */

#include "sendAck.h"

configuration sendAckAppC {}

implementation {

	/****** COMPONENTS *****/
	components MainC, sendAckC as App;
	//add the other components here
	//components new FakeSensorC();
	components new TimerMilliC();
	components new AMSenderC(AM_MY_MSG);
	components new AMReceiverC(AM_MY_MSG);
	components ActiveMessageC;

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
	//Timer interface
	App.MilliTimer -> TimerMilliC;
	//Fake Sensor read
	//App.Read -> FakeSensorC;
}

