
# BEGIN serial.cmd ------------------------------------------------------------

# Set up 2 local serial ports

# serial 1 connected to Keithley2K DMM at 19200 baud
#drvAsynSerialPortConfigure("portName","ttyName",priority,noAutoConnect,
#                            noProcessEos)
drvAsynSerialPortConfigure("serial1", "/dev/ttyS0", 0, 0, 0)
asynSetOption(serial1,0,baud,19200)
asynSetOption(serial1,0,parity,none)
asynSetOption(serial1,0,bits,8)
#asynOctetSetInputEos(const char *portName, int addr,
#                     const char *eosin,const char *drvInfo)
asynOctetSetInputEos("serial1",0,"\r")
# asynOctetSetOutputEos(const char *portName, int addr,
#                       const char *eosin,const char *drvInfo)
asynOctetSetOutputEos("serial1",0,"\r")
# Make port available from the iocsh command line
#asynOctetConnect(const char *entry, const char *port, int addr,
#                 int timeout, int buffer_len, const char *drvInfo)
asynOctetConnect("serial1", "serial1")

# serial 2 connected to Newport MM4000 at 38400 baud
#drvAsynSerialPortConfigure("serial2", "/dev/ttyS1", 0, 0, 0)
#asynSetOption(serial2,0,baud,38400)
#asynSetOption(serial2,0,parity,none)
#asynOctetConnect("serial2", "serial2")
#asynOctetSetInputEos("serial2",0,"\r")
#asynOctetSetOutputEos("serial2",0,"\r")

# Set up ports 1 and 2 on Moxa box


# Load asynRecord records on all ports
dbLoadTemplate("asynRecord.substitutions")


# END serial.cmd --------------------------------------------------------------
