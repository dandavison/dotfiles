#!/bin/bash
zone="Europe/Lisbon" # UTC
echo "PT $(TZ=$zone date +'%H:%M')"
