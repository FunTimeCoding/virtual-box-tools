#!/bin/sh -e

sudo apt-get install msr-tools
sudo modprobe msr
sudo rdmsr 0x3a
# 5 = on
# 1 = off
