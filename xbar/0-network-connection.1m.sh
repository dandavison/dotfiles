#!/bin/bash
if ping -c 1 www.gov.uk &> /dev/null; then
    echo 🟢
else
    echo 🔴
fi