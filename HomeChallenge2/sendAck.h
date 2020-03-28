/**
* @author D'introno, Moreno, Zaniolo
* @date   March 20 2020
*/

#ifndef SENDACK_H
#define SENDACK_H
#define REQ_PERIOD 1000 	// 	1s
#define AM_MY_MSG 6

#define REQ
typedef nx_struct mote_req{
	nx_uint16_t counter;
} mote_req_t;

#define RESP 
typedef nx_struct mote_res{
	nx_uint16_t counter;
	nx_uint16_t meas;
} mote_res_t;

#endif
