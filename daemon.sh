#!/bin/bash

#Variables
status_apache2="null"
status_mysql="null"
status_vsftpd="null"
status_openvpn="null"
status_ssh="null"
apacheSessions="null"
nginxSessions="null"

#API Stuff
apiKey=`cat config.conf | grep 'apiKey = ' | awk -F "apiKey = " '{print $2}'`
secretKey=`cat config.conf | grep 'secretKey = ' | awk -F "secretKey = " '{print $2}'`
serverId=`cat config.conf | grep 'serverId = ' | awk -F "serverId = " '{print $2}'`

services=`cat config.conf | grep 'services = ' | awk -F "services = " '{print $2}'`
netInterface=`cat config.conf | grep 'interface = ' | awk -F "interface = " '{print $2}'`

#NginxSessions
nginxSessions=`netstat -anpt|grep nginx | grep ESTABLISHED | wc -l`


#Getting the variables ready to send
ipAddr=`ifconfig $netInterface | grep "inet addr:" | awk -F ":" '{print $2}' | awk '{print $1}'`
ramTotal=`grep MemTotal /proc/meminfo | awk '{print $2}'`
ramUsed=`grep MemFree /proc/meminfo | awk '{print $2}'`
cpuUsage=`top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'`
hddTotal=`df -h | sed -n 2p | awk '{print $2}' | awk -F "G" '{print $1}'`
hddUsed=`df -h | sed -n 2p | awk '{print $3}' | awk -F "G" '{print $1}'`
hostName=`hostname`
loadAv1m=`uptime | awk -F "average: " '{print $2}' | awk -F "," '{print $1}'`
loadAv5m=`uptime | awk -F "average: " '{print $2}' | awk -F "," '{print $2}'`
loadAv15m=`uptime | awk -F "average: " '{print $2}' | awk -F "," '{print $3}'`
osVersion=`cat /etc/lsb-release | grep "DESCRIPTION" | awk -F '"' '{print $2}'`


each_service=$(echo $services | tr "," "\n")
for x in $each_service
do
	if ps ax | grep -v grep | grep $x > /dev/null
	then
    	declare "status_$x=200"
	else
	declare "status_$x=500"
    	#status_$x="500"
	fi
done


curl -X POST -H "Content-Type: application/json" --data '{"apiKey": "'"$apiKey"'", "secretKey": "'"$secretKey"'", 
"serverId": "'"$serverId"'", "ramTotal": "'"$ramTotal"'", "ramUsed": "'"$ramUsed"'", "hddTotal": "'"$hddTotal"'", 
"hddUsed": "'"$hddUsed"'", "cpuUsage": "'"$cpuUsage"'", "apacheSessions": "'"$apacheSessions"'", "status_apache2": "'"$status_apache2"'", 
"status_mysql": "'"$status_mysql"'", "status_openvpn": "'"$status_openvpn"'", "status_vsftpd": "'"$status_vsftpd"'", 
"status_ssh": "'"$status_ssh"'", "status_nginx": "'"$status_nginx"'", "nginxSessions": "'"$nginxSessions"'", 
"ipAddr": "'"$ipAddr"'", "hostName": "'"$hostName"'", "osVersion": "'"$osVersion"'", "loadAv1m": "'"$loadAv1m"'", 
"loadAv5m": "'"$loadAv5m"'", "loadAv15": "'"$loadAv15"'"}'  -i http://alertize.me/api/




