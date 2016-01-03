#!/bin/bash
# run this as a normal user, e.g., in pi's screen

# wait enough to get current time from ntp. rpi doesn't have an rtc and just
# loads the shutdown time at bootup
sleep 60
$(dirname $(readlink -nf $0))/clock.sh load
$(dirname $(readlink -nf $0))/clock.sh realtime
