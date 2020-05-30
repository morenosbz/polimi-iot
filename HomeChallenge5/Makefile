COMPONENT=NetworkAppC
CFLAGS += -I$(TOSDIR)/lib/printf
#BUILD_EXTRA_DEPS = RadioCountMsg.py RadioCountMsg.class
#CLEAN_EXTRA = RadioCountMsg.py RadioCountMsg.class RadioCountMsg.java

#RadioCountMsg.py: Network.h
#	mig python -target=$(PLATFORM) $(CFLAGS) -python-classname=RadioCountMsg Network.h radio_msg -o $@

#RadioCountMsg.class: RadioCountMsg.java
#	javac RadioCountMsg.java

#RadioCountMsg.java: Network.h
#	mig java -target=$(PLATFORM) $(CFLAGS) -java-classname=RadioCountMsg Network.h radio_msg -o $@


include $(MAKERULES)

