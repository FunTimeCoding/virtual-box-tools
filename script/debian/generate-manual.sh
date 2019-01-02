#!/bin/sh -e

rm -f documentation/man/*.1
ronn --roff documentation/man/*.ronn
