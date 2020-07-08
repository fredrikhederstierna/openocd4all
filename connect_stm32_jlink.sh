#!/bin/bash

# use built in on-board dongle (J-Link)
sudo ./oo4all -f connect_stm32f4_jlink.cfg

# ----- Info about Segger RTT ------
# Patch:
# The patch <rtt.diff> is rebased and slightly modified from openocd:
# [link] http://openocd.zylin.com/#/c/4055/

# Links:
# [1] https://devzone.nordicsemi.com/tutorials/6/
# [2] https://www.segger.com/jlink-rtt.html
# [3] https://www.segger.com/products/debug-probes/j-link/technology/about-real-time-transfer/

# Hints:
# To get information about SEGGER RTT control block location in memory:
#   (gdb) p &(_SEGGER_RTT->acID)
#
# To connect and start RTT (assume 0x2000182c is address to control block above)
# telnet localhost 4444
# rtt setup 0x2000182c 10 "SEGGER RTT"
# rtt start
#
# To get RTT printouts, connect to RTT server (port specified in connect script)):
# telnet localhost 9900

# Connect script setup rttserver, see
# Commands rttserver:
# rttserver start <port> <channel>
# rttserver stop <port>
#
# Commands RTT:
# rtt setup <address> <length> <ID>
# rtt start
# rtt stop
# "List available channels"
# rtt channels
# rtt channellist
