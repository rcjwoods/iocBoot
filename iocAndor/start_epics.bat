#!/bin/bash

export EPICS_CA_MAX_ARRAY_BYTES=30000000
EPICS_DISPLAY_PATH=/local/DPbin/epics/epics_2014-12-01/synApps_5_7/support/adls


start medm -x -macro "P=13ANDOR1:, R=cam1:" andorCCD.adl &
..\..\bin\win32-x86\andorCCDApp st.cmd
pause

