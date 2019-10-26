#!/bin/sh -e

ip addr show eth1 | grep "inet\b" | awk '{print $2}' | cut --delimiter / --field 1
