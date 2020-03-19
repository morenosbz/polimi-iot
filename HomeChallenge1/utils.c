#include "RadioCounterID.h"

int getPeriodFromID(int id){
	if(id == 1){
		return TIMER_PERIOD_MILLI_1;
	}
	if(id == 2){
		return TIMER_PERIOD_MILLI_2;
	}
	if(id == 3){
		return TIMER_PERIOD_MILLI_3;
	}
	//FIXME Add exception for no identified motes
	return 0;
}
