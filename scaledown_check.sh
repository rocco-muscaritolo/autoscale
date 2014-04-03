#!/bin/bash

# Example criteria :
#
#if (metric['sysload_avg'] < 2.0 && metric['percent_memory_used'] < 30 && metric['percent_maxclients'] < 30) {
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
memfree=`sar -r -s $start -e $end | grep Average | tail -n 1 | tr -s ' ' | awk '{print $2}'`
memused=`sar -r -s $start -e $end | grep Average | tail -n 1 | tr -s ' ' | awk '{print $3}'`
memtotal=`awk -v memfree=$memfree -v memused=$memused 'BEGIN { print memfree + memused }'`
buffers=`sar -r -s $start -e $end | grep Average | tail -n 1 | tr -s ' ' | awk '{print $5}'`
cached=`sar -r -s $start -e $end | grep Average | tail -n 1 | tr -s ' ' | awk '{print $6}'`
nocache=`awk -v memused=$memused -v buffers=$buffers -v cached=$cached 'BEGIN { print memused - ( buffers + cached ) }'`

# Find use percentage
mempercentage=`awk -v nocache=$nocache -v memtotal=$memtotal 'BEGIN { print nocache * 100 / memtotal }'`

# Print metric memory
echo "metric percent_memory_used float" $mempercentage


########################################################################################################################


# Find the number of active Apache clients
activeconn=`pgrep -f "httpd|apache2" | wc -l`

# Find the MaxClients setting from Apache config file
if [ -f /etc/apache2/apache2.conf ]
then
        maxclients=`grep MaxClients /etc/apache2/apache2.conf | grep -v '#' | head -n 1 | awk '{print $2}'`
elif [ -f /etc/httpd/conf/httpd.conf ]
then
        maxclients=`grep MaxClients /etc/httpd/conf/httpd.conf | grep -v '#' | head -n 1 | awk '{print $2}'`
fi

# Find use percentage
maxclientuse=`awk -v ac=$activeconn -v mc=$maxclients 'BEGIN { print ac * 100 / mc }'`

# Print metric maxclients
echo "metric percent_maxclients float" $maxclientuse

