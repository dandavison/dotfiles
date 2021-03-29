#!/bin/bash

for s in delta services website; do
    tmux new-session -d -s $s
done
