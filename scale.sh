#!/bin/bash

while true
do

CURRCAP=$(aws --region eu-west-1 autoscaling describe-auto-scaling-groups --auto-scaling-group-names $ASG --output text | head -n 1 | awk '{print $6}')

DESIREDCAP=$(echo "select count( distinct concat(procs.proc_build_id,procs.proc_ppid)) from procs join builds on procs.proc_build_id=builds.build_id and (builds.build_status like 'pending' or (builds.build_status like 'running' and procs.proc_state like 'pending'))" | mysql -h $MYSQLHOST -u $MYSQLUSR -p$MYSQLPWD $MYSQLDB | tail -n1)
DESIREDCAP=$((DESIREDCAP+1))

if [ "$DESIREDCAP" -gt "$CURRCAP" ]
then
  aws --region eu-west-1 autoscaling update-auto-scaling-group --auto-scaling-group-name $ASG --desired-capacity $DESIREDCAP
elif [ "$DESIREDCAP" == 1 ] && [ "$CURRCAP" -gt 1 ]
then
  pssh -O StrictHostKeyChecking=no -O UserKnownHostsFile=/dev/null -p 256 -l ubuntu -x '-i /home/ec2-user/.dronekey' -h /home/ec2-user/list -t 5 'touch -d "6 min ago" /home/ubuntu/used'
fi

sleep 10

done
