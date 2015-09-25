




set_requestfile_path("./")
set_requestfile_path("$(ADCORE)", "ADApp/Db")
set_requestfile_path("$(AUTOSAVE)", "asApp/Db")
set_requestfile_path("$(BUSY)", "busyApp/Db")
set_requestfile_path("$(CALC)", "calcApp/Db")
set_requestfile_path("$(XSPRESS3)","xspress3App/Db")
set_requestfile_path("$(SSCAN)", "sscanApp/Db")
set_savefile_path("./autosave")
set_pass0_restoreFile("auto_settings.sav")
set_pass1_restoreFile("auto_settings.sav")
save_restoreSet_status_prefix("$(PREFIX)")
dbLoadRecords("$(AUTOSAVE)/asApp/Db/save_restoreStatus.db", "P=$(PREFIX)")

epicsEnvSet("BUILT_SETTINGS", "built_settings.req")
autosaveBuild("$(BUILT_SETTINGS)", "_settings.req", 1)

# Autosave menu
dbLoadRecords("$(AUTOSAVE)/asApp/Db/configMenu.db", "P=$(PREFIX),CONFIG=setup")
set_requestfile_path("$(AUTOSAVE)/asApp/Db")


