/**
*	Politecnico di Milano
*	IoT - Home Challenge 5
*	Message structure
*/

#ifndef MQTT_RANDOM_H
#define MQTT_RANDOM_H

typedef nx_struct mqtt_random_msg {
  nx_uint16_t src;			// Source (sender) Mote
  nx_uint16_t counter;		// Counter value
} mqtt_random_msg_t;

enum {
	AM_RADIO_COUNT_MSG = 6,
	TIMER_PERIOD_MILLI = 5000,	// 5s
};

#endif
