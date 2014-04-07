#!/bin/bash

# Example criteria :
#
#if (metric['sysload_avg'] < 2.0 && metric['percent_memory_used'] < 30 {
#  return new AlarmStatus(CRITICAL, 'Auto Scale servers have been over provisioned. Auto #scale group is being scaled down!');
#}
#
#return new AlarmStatus(OK, 'Auto Scale servers are being used too heavily for safe scale down.');

########################################################################################################################


# Getting time parameters for sar command
end=`date | awk '{ print $4}'`
start=`date -d "1 hour ago" | awk '{ print $4}'`


# Find average sysload from last hour
sysloadavg=`sar -q -s $start -e $end | grep Average | tail -n 1 | tr -s ' ' | awk '{print $4}'`

# Print metric system load
echo "metric sysload_avg float" $sysloadavg


########################################################################################################################


# Setting proper values for average memory usage from last hour
memavg=`sar -r -s $start -e $end | grep Average | tail -n 1 | tr -s ' '`

# Find use percentage
mempercentage=`echo $memavg | awk '{ print ( $3 - ( $5 + $6 ) ) * 100 / ( $2 + $3 ) }'`

# Print metric memory
echo "metric percent_memory_used float" $mempercentage


