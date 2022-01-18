#!/bin/bash

cd /sys/kernel/config/usb_gadget/
mkdir -p display-pi
cd display-pi
echo 0x1d6b > idVendor # Linux Foundation
echo 0x0104 > idProduct # Multifunction Composite Gadget
echo 0x0100 > bcdDevice # v1.0.0
echo 0x0200 > bcdUSB # USB2
mkdir -p strings/0x409
echo "fedcba9876543210" > strings/0x409/serialnumber
echo "Ben Hardill" > strings/0x409/manufacturer
echo "Display-Pi USB Device" > strings/0x409/product
mkdir -p configs/c.1/strings/0x409
echo "Config 1: ECM network" > configs/c.1/strings/0x409/configuration
echo 250 > configs/c.1/MaxPower
# Add functions here
# see gadget configurations below
# End functions

mkdir -p functions/ecm.usb0
HOST="00:dc:c8:f7:75:15" # "HostPC"
SELF="00:dd:dc:eb:6d:a1" # "BadUSB"
echo $HOST > functions/ecm.usb0/host_addr
echo $SELF > functions/ecm.usb0/dev_addr
ln -s functions/ecm.usb0 configs/c.1/

mkdir -p functions/acm.usb0
ln -s functions/acm.usb0 configs/c.1/

udevadm settle -t 5 || :
ls /sys/class/udc > UDC

ifup usb0