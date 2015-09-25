rem This batch file starts the software displays for detectors from EPICS

rem set path=%path%;/home/hammonds/epics/base-3.14.10/bin/cygwin-x86
rem echo %EPICS_DISPLAY_PATH%
rem set DISPLAY=localhost:0
rem set XKEYSYMDB=c:\Program Files\EPICS WIN32 Extensions\XKeysymDB
rem set XLOCALEDIR=c:\Program Files\EPICS WIN32 Extensions\Locale
rem set EPICS_CA_ADDR_LIST=164.54.188.65

set EPICS_DISPLAY_PATH=C:/cygwin/home/linkam/epics/ioc/EPlinkam1/EPlinkam1App/op/adl;C:/cygwin/home/linkam/epics/synApps_5_4_1/support/all_adl
start medm -x -attach -macro "P=EPLinkam1:, R=asyn_1" ci94.adl

