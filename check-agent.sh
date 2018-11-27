#!/bin/bash 

USED=$HOME/used

WORK=$(docker ps -q | wc -l)

REGION=$(ec2metadata --availability-zone | rev | cut -c 2- | rev)

aws --region $REGION cloudwatch put-metric-data --namespace DRONE --dimensions Name=Agent --metric-name DroneAgentProcs --value $WORK

if [ $WORK -gt 1 ]
then
    touch $USED
    exit
else
    if [ -f $USED ] 
    then
        if [ `expr $(date +%s) - $(stat -c %Y $USED)` -gt 300  ]
        then
            if [ $(curl -s localhost:3000/varz | awk -F ',' '{print $2}' | cut -d ':' -f 2) -eq 1 ]
            then
                exit
            else
                docker stop drone_agent
                aws --region $REGION autoscaling terminate-instance-in-auto-scaling-group --instance-id $(ec2metadata --instance-id) --should-decrement-desired-capacity
            fi
        fi
    fi
fi

