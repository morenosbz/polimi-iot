/**
 *	Politecnico di Milano
 *	IoT - Final Project
 *	Components relationship
 */

#define NEW_PRINTF_SEMANTICS
#include "printf.h"
#include "KeepYourDistance.h"

/**
 * @author D'introno, Moreno, Zaniolo
 * @date   July 2020
 */

configuration KeepYourDistanceAppC {}
implementation {
    components MainC, KeepYourDistanceC as App, RandomC;
    components new AMSenderC(AM_RADIO_COUNT_MSG);
    components new AMReceiverC(AM_RADIO_COUNT_MSG);
    components new TimerMilliC();
    components ActiveMessageC;

    /*
        Serial print components
    */
    components SerialPrintfC;

    App.Boot-> MainC.Boot;

    App.Receive-> AMReceiverC;
    App.AMSend-> AMSenderC;
    App.AMControl-> ActiveMessageC;
    App.MilliTimer-> TimerMilliC;
    App.Packet-> AMSenderC;
    
}
