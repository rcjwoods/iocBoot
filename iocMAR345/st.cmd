< envPaths.linux
errlogInit(20000)

dbLoadDatabase("$(TOP)/dbd/mar345App.dbd")
mar345App_registerRecordDeviceDriver(pdbbase) 


epicsEnvSet("DETECTOR", "mar345")

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


epicsEnvSet("PORT",   "MAR")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "3450")
epicsEnvSet("YSIZE",  "3450")
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")


###
# Create the asyn port to talk to the MAR on port 5001
drvAsynIPPortConfigure("marServer","localhost:5001")
# Set the input and output terminators.
asynOctetSetInputEos("marServer", 0, "\n")
asynOctetSetOutputEos("marServer", 0, "\n")
asynSetTraceIOMask("marServer",0,2)
#asynSetTraceMask("marServer",0,255)

mar345Config("$(PORT)", "marServer", 20, 200000000)
asynSetTraceIOMask("$(PORT)",0,2)
#asynSetTraceMask("$(PORT)",0,255)
dbLoadRecords("$(ADMAR345)/db/mar345.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,MARSERVER_PORT=marServer")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)
dbLoadRecords("$(ADCORE)/db/NDPluginBase.template","P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),NDARRAY_ADDR=0")
dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,TYPE=Int16,FTVL=SHORT,NELEMENTS=12000000")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd

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

#asynSetTraceMask("$(PORT)",0,3)
#asynSetTraceIOMask("$(PORT)",0,4)

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


