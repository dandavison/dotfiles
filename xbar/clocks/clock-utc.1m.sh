#!/bin/bash
zone="Europe/Lisbon" # UTC
echo "$(TZ=$zone date +'%H:%M')"
