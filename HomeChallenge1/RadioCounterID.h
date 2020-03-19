/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Message structure
*/

#ifndef RADIO_COUNTER_ID_H
#define RADIO_COUNTER_ID_H

typedef nx_struct id_count_msg {
  nx_uint16_t src;			// Source (sender) Mote
  nx_uint16_t counter;		// Counter value
} id_count_msg_t;

enum {
	AM_RADIO_COUNT_MSG = 6,
	TIMER_PERIOD_MILLI_1 = 1000,	// 1Hz
	TIMER_PERIOD_MILLI_2 = 333,		// 3Hz
	TIMER_PERIOD_MILLI_3 = 200,		// 5Hz
};

#endif
