#!/bin/sh
/usr/bin/xrdadler32 $1 | /bin/awk '{print $1}'
