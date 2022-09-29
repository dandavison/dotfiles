#!/bin/bash
zone="America/New_York"
echo "New York $(TZ=$zone date +'%H:%M %a %b %d')"
