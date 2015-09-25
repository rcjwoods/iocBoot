# Linux-x86 startup script

< envPaths


epicsEnvSet("DETECTOR", "linkam")




# save_restore.cmd needs the full path to the startup directory, which
# envPaths currently does not provide
epicsEnvSet(STARTUP,$(TOP)/iocBoot/$(IOC))

# Increase size of buffer for error logging from default 1256
errlogInit(20000)

# Specify largest array CA will transport
# Note for N sscanRecord data points, need (N+1)*8 bytes, else MEDM
# plot doesn't display
#epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 64008

# set the protocol path for streamDevice
streamPath="$(DPEPICS)/Linkam/EPlinkam1/EPLinkam1App/Db"
epicsEnvSet("STREAM_PROTOCOL_PATH", "$(DPEPICS)/Linkam/EPlinkam1/EPLinkam1App/Db")

################################################################################
# Tell EPICS all about the record types, device-support modules, drivers,
# etc. in the software we just loaded (EPLinkam1.munch)
dbLoadDatabase("$(TOP)/dbd/iocEPLinkam1Linux.dbd")
iocEPLinkam1Linux_registerRecordDeviceDriver(pdbbase)

#########################################
#	Detector Pool Specific Things
#########################################
< /local/config/xrd_config.epics

epicsEnvSet("PREFIX", "$(SECTOR)$(DETECTOR)$(SUFFIX):")

epicsEnvSet("IOC","ioc$(SECTOR)$(DETECTOR)$(SUFFIX)")

# Alive Record
dbLoadRecords("$(ALIVE)/aliveApp/Db/alive.db","P=$(PREFIX),RHOST=164.54.100.11")

#DevIOCStats
#dbLoadRecords("$(DEVIOCSTATS)/db/iocAdminSoft.db", "IOC=$(SECTOR)$(DETECTOR)$(SUFFIX)")

# caputrecorder
asSetFilename("$(IOCBOOT)/../accessSecurity.acf")
dbLoadRecords("$(CAPUTRECORDER)/caputRecorderApp/Db/caputPoster.db","P=$(PREFIX),N=300")

##########################################



### save_restore setup
# We presume a suitable initHook routine was compiled into EPLinkam1.munch.
# See also create_monitor_set(), after iocInit() .
< save_restore.cmd

# serial support
< serial.cmd

### streamDevice example
#dbLoadRecords("$(TOP)/EPlinkam1App/Db/streamExample.db","P=$(PREFIX),PORT=serial1")


dbLoadRecords("$(CALC)/calcApp/Db/userCalcs10.db","P=$(PREFIX)")
dbLoadRecords("$(CALC)/calcApp/Db/userCalcOuts10.db","P=$(PREFIX)")
dbLoadRecords("$(CALC)/calcApp/Db/userStringCalcs10.db","P=$(PREFIX)")
dbLoadRecords("$(CALC)/calcApp/Db/userStringSeqs10.db","P=$(PREFIX)")
dbLoadRecords("$(CALC)/calcApp/Db/userArrayCalcs10.db","P=$(PREFIX),N=2000")
dbLoadRecords("$(CALC)/calcApp/Db/userTransforms10.db","P=$(PREFIX)")
# extra userCalcs (must also load userCalcs10.db for the enable switch)
dbLoadRecords("$(CALC)/calcApp/Db/userCalcN.db","P=$(PREFIX),N=I_Detector")
dbLoadRecords("$(CALC)/calcApp/Db/userAve10.db","P=$(PREFIX)")
## 4-step measurement
#dbLoadRecords("$(STD)/stdApp/Db/4step.db", "P=$(PREFIX)")
# interpolation
dbLoadRecords("$(CALC)/calcApp/Db/interp.db", "P=$(PREFIX),N=2000")
# array test
dbLoadRecords("$(CALC)/calcApp/Db/arrayTest.db", "P=$(PREFIX),N=2000")

#LinkamScientific CI-94 from Eqpt Pool (JPH, 2008-06-03)
dbLoadRecords("$(TOP)/EPLinkam1App/Db/ci94.db", "P=$(PREFIX),PORT=serial1")


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



###############################################################################
iocInit

### Start up the autosave task and tell it what to do.
# The task is actually named "save_restore".
# Note that you can reload these sets after creating them: e.g., 
# reload_monitor_set("auto_settings.req",30,"P=$(PREFIX)")
#save_restoreDebug=20
#
# save positions every five seconds
#create_monitor_set("auto_positions.req",5,"P=$(PREFIX)")
# save other things every thirty seconds
create_monitor_set("auto_settings.req",30,"P=$(PREFIX)")

### Start the saveData task.
saveData_Init("saveData.req", "P=$(PREFIX)")


dbcar(0,1)

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

