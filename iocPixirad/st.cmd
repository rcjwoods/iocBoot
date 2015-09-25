< envPaths.linux
errlogInit(20000)

dbLoadDatabase("$(TOP)/dbd/pixiradApp.dbd")
pixiradApp_registerRecordDeviceDriver(pdbbase) 

epicsEnvSet("DETECTOR", "pixirad")

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


epicsEnvSet("COMMAND_PORT", "PIXI_CMD")
epicsEnvSet("STATUS_PORT", "2224")
epicsEnvSet("DATA_PORT", "2223")
epicsEnvSet("DATA_PORT_BUFFERS", "1500")
epicsEnvSet("PORT",   "PIXI")
epicsEnvSet("QSIZE",  "20")
epicsEnvSet("XSIZE",  "476")
epicsEnvSet("YSIZE",  "512")
epicsEnvSet("NCHANS", "2048")
# The maximum number of frames buffered in the NDPluginCircularBuff plugin
epicsEnvSet("CBUFFS", "500")
# The search path for database files
epicsEnvSet("EPICS_DB_INCLUDE_PATH", "$(ADCORE)/db")


###
# Create the asyn port to talk to the Pixirad box on port 2222.
drvAsynIPPortConfigure("$(COMMAND_PORT)","192.168.0.1:2222 HTTP", 0, 0, 0)
asynOctetSetOutputEos($(COMMAND_PORT), 0, "\n")
asynSetTraceIOMask($(COMMAND_PORT), 0, 2)
#asynSetTraceMask($(COMMAND_PORT), 0, 9)

pixiradConfig("$(PORT)", "$(COMMAND_PORT)", "$(DATA_PORT)", "$(STATUS_PORT)", $(DATA_PORT_BUFFERS), $(XSIZE), $(YSIZE))
asynSetTraceIOMask($(PORT), 0, 2)
#asynSetTraceMask($(PORT), 0, 255)

dbLoadRecords("$(ADPIXIRAD)/db/pixirad.template","P=$(PREFIX),R=cam1:,PORT=$(PORT),ADDR=0,TIMEOUT=1,SERVER_PORT=$(COMMAND_PORT)")

# Create a standard arrays plugin
NDStdArraysConfigure("Image1", 5, 0, "$(PORT)", 0, 0)

dbLoadRecords("$(ADCORE)/db/NDStdArrays.template", "P=$(PREFIX),R=image1:,PORT=Image1,ADDR=0,TIMEOUT=1,NDARRAY_PORT=$(PORT),TYPE=Int16,FTVL=SHORT,NELEMENTS=243712")

# Load all other plugins using commonPlugins.cmd
< $(ADCORE)/iocBoot/commonPlugins.cmd
set_requestfile_path("$(ADPIXIRAD)/pixiradApp/Db")

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
create_monitor_set("auto_settings.req", 30,"P=$(PREFIX)")


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
