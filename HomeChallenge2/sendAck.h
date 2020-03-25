/**
* @author D'introno, Moreno, Zaniolo
* @date   March 20 2020
*/

#ifndef SENDACK_H
#define SENDACK_H
#define REQ_PERIOD 1000 	// 	1s
#define AM_MY_MSG 6
//payload of the msg
typedef nx_struct my_msg {
	//field 1
	//field 2
	//field 3
} my_msg_t;

#define REQ
typedef nx_struct mote_req{
	nx_uint8_t req;
	nx_uint16_t counter;
} mote_req_t;

#define RESP 
typedef nx_struct mote_res{
	nx_uint8_t req;
	nx_uint16_t counter;
} mote_res_t;

#endif
