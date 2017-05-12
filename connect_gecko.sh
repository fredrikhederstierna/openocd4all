#!/bin/bash

# use built in on-board dongle (J-Link)
sudo ./oo4all -f board/efm32.cfg

# use external dongle ST-Link-v2
#sudo ./oo4all -f connect_gecko_stlink.cfg
