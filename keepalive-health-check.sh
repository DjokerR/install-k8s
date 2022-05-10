#!/bin/sh
ls /var/run/keepalived.pid
if [ $? = 0 ]; then
   echo "health check is success"
   exit 0
else
   echo "health check is falied"
   systemctl stop keepalived
   exit 1
fi
