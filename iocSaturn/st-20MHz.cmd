< envPaths

epicsEnvSet("DETECTOR", "vortex")

### Register all support components
dbLoadDatabase("$(DXP)/dbd/dxp.dbd")
dxp_registerRecordDeviceDriver(pdbbase)

#########################################
#	Detector Pool Specific Things
#########################################
< /local/config/xrd_config.epics

epicsEnvSet("PREFIX", "$(SECTOR)$(DETECTOR)$(SUFFIX):")

epicsEnvSet("IOC","ioc$(SECTOR)$(DETECTOR)$(SUFFIX)")

# Alive Record
dbLoadRecords("$(ALIVE)/aliveApp/Db/alive.db","P=$(PREFIX),RHOST=164.54.100.11")
##########################################


# Set EPICS_CA_MAX_ARRAY_BYTES large enough for the trace buffers
epicsEnvSet EPICS_CA_MAX_ARRAY_BYTES 100000

# On Linux execute the following command so that libusb uses /dev/bus/usb
# as the file system for the USB device.  
# On some Linux systems it uses /proc/bus/usb instead, but udev
# sets the permissions on /dev, not /proc.
#epicsEnvSet USB_DEVFS_PATH /dev/bus/usb

# Initialize the XIA software
# Set logging level (1=ERROR, 2=WARNING, 3=XXX, 4=DEBUG)
xiaSetLogLevel(2)
# Edit saturn.ini to match your Saturn speed (20 or 40 MHz), 
# pre-amp type (reset or RC), and interface type (EPP, USB 1.0, USB 2.0)
xiaInit("saturn-20MHz.ini")
xiaStartSystem

NDDxpConfig("DXP1", 1, 10, 42000000)
asynSetTraceIOMask("DXP1", 0, 2)
#asynSetTraceMask("DXP1", 0, 255)

dbLoadRecords("$(DXP)/dxpApp/Db/dxpSystem.template",   "P=$(PREFIX), R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/dxpApp/Db/dxpHighLevel.template","P=$(PREFIX), R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/dxpApp/Db/dxpSaturn.template",   "P=$(PREFIX), R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/dxpApp/Db/dxpLowLevel.template", "P=$(PREFIX), R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/dxpApp/Db/dxpSCA_16.template",   "P=$(PREFIX), R=dxp1:,IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(DXP)/dxpApp/Db/mcaCallback.template", "P=$(PREFIX), R=mca1, IO=@asyn(DXP1 0 1)")
dbLoadRecords("$(MCA)/mcaApp/Db/mca.db",               "P=$(PREFIX), M=mca1, DTYP=asynMCA,INP=@asyn(DXP1 0),NCHAN=2048")

# Template to copy MCA ROIs to DXP SCAs
dbLoadTemplate("roi_to_sca.substitutions")

# Setup for save_restore
< $(DXP)/iocBoot/save_restore.cmd
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

### Scan-support software
# crate-resident scan.  This executes 1D, 2D, 3D, and 4D scans, and caches
# 1D data, but it doesn't store anything to disk.  (See 'saveData' below for that.)
dbLoadRecords("$(SSCAN)/sscanApp/Db/scan.db","P=$(PREFIX),MAXPTS1=2000,MAXPTS2=1000,MAXPTS3=10,MAXPTS4=10,MAXPTSH=2048")

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

### Start up the autosave task and tell it what to do.
# Save settings every thirty seconds
create_monitor_set("auto_settings.req", 30, P=$(PREFIX))

### Start the saveData task.
saveData_Init("saveData.req", "P=$(PREFIX)")

#########################################
#	Detector Pool Specific Things
#########################################

# Autosave menu
create_manual_set("setupMenu.req","P=$(PREFIX),CONFIG=setup,CONFIGMENU=1")

#	Beamlilne custom autosave and plugin add-ons
< /local/DPbin/epics/Custom_AD_Plugins/ADPluginAddOns-AS.cmd

#########################################


