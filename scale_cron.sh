
#!/bin/bash

load=`sh /root/scaledown_check.sh | grep sysload_avg | awk '{print $4}'`
mem=`sh /root/scaledown_check.sh | grep percent_memory_used | awk '{print $4}'`
maxclients=`sh /root/scaledown_check.sh | grep percent_maxclients | awk '{print $4}'`

if awk -v ld=$load 'BEGIN {exit !(ld < 2)}' && awk -v mem=$mem 'BEGIN {exit !(mem < 30)}' && awk -v cli=$maxclients 'BEGIN {exit !(cli < 30)}'
then
	echo `date` "Autoscale load check: Scaling DOWN by 1 server!"
        curl -X POST https://iad.autoscale.api.rackspacecloud.com/v1.0/execute/1/13aa6c05ca918b7f0cf6f04336176e4b2ba7359ab44f7f9b555a7a72b7d088b5/
else
        echo `date` "Autoscale load check: Not ready for scale down"
fi

echo "  Average sysload = $load
        Average memory use = $mem %
        Average MaxClients use = $maxclients %"

