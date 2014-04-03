#!/bin/bash

# Example criteria :
#
#if (metric['sysload_avg'] < 6.0 && metric['percent_memory_used'] < 30 && metric['percent_maxclients'] < 30) {
#  return new AlarmStatus(CRITICAL, 'Auto Scale servers have been over provisioned. Auto #scale group is being scaled down!');
#}
#
#return new AlarmStatus(OK, 'Auto Scale servers are being used too heavily for safe scale #down.');



# Getting time parameters for sar command
endtime=`date | gawk '{ print $4}'`
starttime=`date -d "1 hour ago" | gawk '{ print $4}'`


# Find average sysload from last hour
sysloadavg=`sar -q -s $starttime -e $endtime | grep Average | tail -n 1 | tr -s ' ' | gawk '{print $4}'`

# Print metric system load
echo "metric sysload_avg float" $sysloadavg


# Setting proper values for average memory usage from last hour
kbmemfree=`sar -r -s $starttime -e $endtime | grep Average | tail -n 1 | tr -s ' ' | gawk '{print $2}'`
kbmemused=`sar -r -s $starttime -e $endtime | grep Average | tail -n 1 | tr -s ' ' | gawk '{print $3}'`
memtotal=`echo $kbmemfree + $kbmemused | bc`
kbbuffers=`sar -r -s $starttime -e $endtime | grep Average | tail -n 1 | tr -s ' ' | gawk '{print $5}'`
kbcached=`sar -r -s $starttime -e $endtime | grep Average | tail -n 1 | tr -s ' ' | gawk '{print $6}'`
withoutcache=`echo $kbmemused - \($kbbuffers+$kbcached\) | bc`

# Find use percentage
mempercentage=`echo $withoutcache \* 100 / $memtotal | bc`

# Print metric memory usage
echo "metric percent_memory_used int" $mempercentage


# Find the number of active Apache clients
activeconn=`pgrep -f "httpd|apache2" | wc -l`

# Find the MaxClients setting from Apache config file
if [ -f /etc/apache2/apache2.conf ]
then
        maxclients=`grep MaxClients /etc/apache2/apache2.conf | grep -v '#' | head -n 1 | gawk '{print $2}'`
elif [ -f /etc/httpd/conf/httpd.conf ]
then
        maxclients=`grep MaxClients /etc/httpd/conf/httpd.conf | grep -v '#' | head -n 1 | gawk '{print $2}'`
fi

# Find use percentage
maxclientuse=`echo $activeconn \* 100 / $maxclients | bc`

echo "metric percent_maxclients int" $maxclientuse
