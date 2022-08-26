#!/bin/bash
zone="America/Los_Angeles"
echo "San Francisco $(TZ=$zone date +'%a %H:%M')"
