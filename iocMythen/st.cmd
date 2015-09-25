< envPaths

# Specify largest array CA will transport
# Note for N sscanRecord data points, need (N+1)*8 bytes, else MEDM
# plot doesn't display
epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 3000000

dbLoadDatabase("$(TOP)/dbd/mythenApp.dbd")

mythenApp_registerRecordDeviceDriver(pdbbase)

epicsEnvSet("DETECTOR", "mythen")

#drvAsynIPPortConfigure("portName","hostInfo",priority,noAutoConnect,
#                        noProcessEos)
drvAsynIPPortConfigure("IP_M1K", "192.168.0.90:1030 UDP", 0, 0, 1)


#asynOctetSetInputEos("IP_M1K",0,"\r\n")
asynOctetSetOutputEos("IP_M1K",0,"\r")

asynSetTraceIOMask("IP_M1K",0,6)
asynSetTraceMask("IP_M1K",0,3)


#########################################
#	Detector Pool Specific Things
#########################################
< /local/config/xrd_config.epics

epicsEnvSet("PREFIX", "$(SECTOR)$(DETECTOR)$(SUFFIX):")

epicsEnvSet("IOC","ioc$(SECTOR)$(DETECTOR)$(SUFFIX)")

# Alive Record
dbLoadRecords("$(ALIVE)/aliveApp/Db/alive.db","P=$(PREFIX),RHOST=164.54.100.11")

#DevIOCStats
dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db", "IOC=$(SECTOR)$(DETECTOR)$(SUFFIX)")

# caputrecorder
asSetFilename("$(IOCBOOT)/../accessSecurity.acf")
dbLoadRecords("$(CAPUTRECORDER)/caputRecorderApp/Db/caputPoster.db","P=$(PREFIX),N=300")

##########################################


epicsEnvSet("PORT",   "SD1")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "1280")
epicsEnvSet("YSIZE",  "1")
epicsEnvSet("NCHANS", "1280")
epicsEnvSet("CBUFFS", "100")
epicsEnvSet("EPICS_DB_INCLUDE_PATH","$(ADCORE)/db")

# mythenConfig (
#               portName,       # The name of the asyn port driver to be created.
#               IPPortName,     # The network port connection to the Mythen
#               maxBuffers,     # The maximum number of NDArray buffers that the NDArrayPool for this driver is 
#                                 allowed to allocate. Set this to -1 to allow an unlimited number of buffers.
#               maxMemory)      # The maximum amount of memory that the NDArrayPool for this driver is 
#                                 allowed to allocate. Set this to -1 to allow an unlimited amount of memory.
mythenConfig("SD1", "IP_M1K", -1,-1)

asynSetTraceMask("IP_M1K",0,1)

dbLoadRecords("$(ADCORE)/db/ADBase.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADCORE)/db/NDFile.template",   "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")
dbLoadRecords("$(ADMYTHEN)/mythenApp/Db/mythen.template",        "P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
# This is now included in NDStdArrays
#dbLoadRecords("$(ADCORE)/db/NDPluginBase.template","P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0")
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0,TYPE=Float64,FTVL=DOUBLE,NELEMENTS=$(NCHANS)")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd

# Load asynRecord records on Mythen communication
dbLoadRecords("$(ASYN)/db/asynRecord.db", "P=$(PREFIX),R=asyn_1,PORT=IP_M1K,ADDR=0,OMAX=256,IMAX=256")


#set_requestfile_path("$(TOP)/mythenApp/Db")
set_requestfile_path("$(ADMYTHEN)/mythenApp/Db")

#########################################
#	Detector Pool Specific Things
#########################################

#	Beamlilne custom autosave and plugin add-ons
< /local/DPbin/epics/Custom_AD_Plugins/ADPluginAddOns.cmd

# Autosave menu
dbLoadRecords("$(AUTOSAVE)/asApp/Db/configMenu.db", "P=$(PREFIX),CONFIG=setup")
set_requestfile_path("$(AUTOSAVE)/asApp/Db")
save_restoreSet_FilePermissions(0666) 			# Sets autosave files permissions to 0666 or RW for everyone
set_pass0_restoreFile("auto_settings.sav", "P=$(PREFIX)")
set_pass1_restoreFile("auto_settings.sav", "P=$(PREFIX)")

#########################################

iocInit()

# save things every thirty seconds
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX),D=cam1:")

#########################################
#	Detector Pool Specific Things
#########################################

# Autosave menu
create_manual_set("setupMenu.req","P=$(PREFIX),CONFIG=setup,CONFIGMENU=1")

#	Beamlilne custom autosave and plugin add-ons
< /local/DPbin/epics/Custom_AD_Plugins/ADPluginAddOns-AS.cmd

#caputRecorder
registerCaputRecorderTrapListener("$(PREFIX)caputRecorderCommand")
#########################################
