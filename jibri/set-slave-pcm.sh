#!/bin/bash

ASOUNDRC='/home/jibri/.asoundrc'

## find first Loopback device that is not busy
for DEV in $(aplay -l | awk '/Loopback.*device 0/ {print $3}'); do 
        if !(aplay -D dmix:CARD=$DEV /dev/zero 2>&1 | grep -i 'busy') >/dev/null; then
                break
        fi
done

echo "will set '$DEV' as slave.pcm device in $ASOUNDRC"

sed -i "s/Loopback\(_[0-9]\{1,2\}\)\?/$DEV/g" $ASOUNDRC
