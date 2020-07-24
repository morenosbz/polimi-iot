/**
 *	Politecnico di Milano
 *	IoT - Final Project
 *	Message structure
 */

#ifndef KEEP_YOUR_DISTANCE_H
#define KEEP_YOUR_DISTANCE_H

typedef nx_struct kyd_msg {
    nx_uint16_t near;        // Near Mote
    nx_uint16_t src;		 // Sender Mote
        
}
kyd_msg_t;

enum {
    AM_RADIO_COUNT_MSG = 6,
    TIMER_PERIOD_MILLI = 500, // 500ms
};

#endif
