#!/bin/bash
zone="America/New_York"
echo " NYC $(TZ=$zone date +'%H:%M %a %b %d')"
