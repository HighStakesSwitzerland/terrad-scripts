#!/bin/bash

#
# Upstart monitoring script for oracle missed votes.
# Run with "setuid root" to be able to restart the feeder service
#

VALIDATOR=$1 # terravaloper address of your validator
LCD_HOST=$2 # url to lcd, ex "http://sentry-node:1317" (with quotes)
echo "Starting oracle-monitoring script..."

# Check every 60 seconds if the missing vote count increases. If more than 2 missed votes in 60 sec, restart the process
while (true); do
    missed_votes=$(curl -s $LCD_HOST/oracle/voters/$VALIDATOR/miss  | jq ".result" | sed s/\"//g)
    echo "Got $missed_votes missed votes"
    sleep 60

    last_missed_votes=$(curl -s $LCD_HOST/oracle/voters/$VALIDATOR/miss  | jq ".result" | sed s/\"//g)
    echo "Got $last_missed_votes missed votes"
    difference=$(expr $last_missed_votes - $missed_votes)

    if [[ $difference -eq 1 ]]
    then
	echo "Missed 1 vote, not restarting"
    fi
       
    if [[ $difference -gt 2 ]]
    then
	echo "Missed $difference votes, restarting oracle!"
	## uncomment below
	# su -c "restart terra-price-feeder" # for upstart
	sudo systemctl restart terrad-price-feeder # for systemctl

	#sendmail must be configured, otherwise comment next lines
	sendmail -t 'contact@stakers.finance' << EOF
Subject: Oracle feeder restarted!
Missed votes count: $difference
Current cound: $last_missed_votes
EOF
	sleep 60 # wait for stabilisation
    fi
done;
