/**
*	Politecnico di Milano
*	IoT - Home Challenge 1
*	Message structure
*/

#ifndef RADIO_COUNT_TO_LEDS_H
#define RADIO_COUNT_TO_LEDS_H

typedef nx_struct radio_count_msg {
  nx_uint16_t counter;		// Counter value
} radio_count_msg_t;

enum {
  AM_RADIO_COUNT_MSG = 6,
  TIMER_PERIOD_MILLI = 250		// TODO Check this value
};

#endif
