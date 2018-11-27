# droneautoscaling
Drone Autoscaling scripts

## Agent cron ##
* * * * * check-agent.sh

## Server cron ##
* * * * * flock -w1 lock scale.sh
