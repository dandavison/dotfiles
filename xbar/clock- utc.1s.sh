#!/bin/bash
zone="UTC"
echo "UTC $(TZ=$zone date +'%H:%M:%S')"
