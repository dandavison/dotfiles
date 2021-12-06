#!/bin/bash
zone="America/Los_Angeles"
echo "$(TZ=$zone date +'%a %H:%M')"
