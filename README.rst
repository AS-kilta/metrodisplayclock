metro station display clock driver
==================================

The analog clock on those old red Finnish metro station displays is driven by
12 V pulses with alternating polarity. One pulse turns the minute hand one step
forward, and the hour hand is automatic. The required pulse duration is about
0.5 seconds. Current draw of both the two coils is approximately 50 mA at 12 V.

It's not possible to go backwards electrically, but there is a gear inside that
can be turned manually. It's also okay to just grab the minute hand.

This repo contains a super simple script that pulses two Linux GPIOs every
minute. This runs on a `Raspberry Pi`_ in AS_ guild room. Those pins are
connected directly to an H bridge. TODO: fix the circuit to use enable and
direction pins, so that it wouldn't be possible to blow up the transistors.

.. _Raspberry Pi: http://elinux.org/RPi_Low-level_peripherals#General_Purpose_Input.2FOutput_.28GPIO.29
.. _AS: http://as.ayy.fi/

Usage
-----

Setup: run ``$your_path/clock.sh register`` as root when booting, e.g. in
``/etc/rc.local`` or use cron's ``@reboot``. This sets up the gpio sysfs
exports.

Realtime operation: run ``$your_path/clock.sh realtime`` somewhere, as a normal
user. I still have this in a screen session so that it could be ^Z'd
temporarily while in development. ``clock.sh [even|odd|both]`` pulses the even,
odd, or both pins ("even" pin is one that turns the minute hand to an even
number using the H bridge.) ``clock.sh fast`` advances the clock as fast as
possible (0.5 s for one turn was found to be okay experimentally).

It takes 30 seconds to advance a whole hour, or six minutes for 24 hours.
Faster operation is not really reliable or the gear mechanism would skip pulses
sometimes.

The mechanics in the clock have no feedback, so it's not possible to read out
the time automatically without machine vision. Therefore, if you ever reboot,
you also need to run ``clock.sh load`` at boot time, between ``register`` and
``realtime``.

``clock.sh save`` just puts the current time to ``time.txt`` as an unix time.
This is done automatically during the "realtime" mode. ``clock.sh load``
assumes that the clock displays the time found in ``time.txt``, and spins the
clock until its time matches the current time, then exits. This feature
probably has dozens of corner case bugs, so beware.

If the clock hands need to be rotated manually to some arbitrary time, use
``date -d $time +%s > time.txt``. ``$time`` is whatever reads on the clock
face, e.g., 13:37.

The clock box has two clock faces facing in opposite directions but just one
input; if they go out of sync for some reason, one must be rotated manually to
match the other, unless you re-wire them.

TODO: investigate why the other face lags sometimes. Maybe it needs lubrication
or longer pulses.

IRL
---

.. image:: face.jpg

.. image:: gear.jpg

License
-------

`Don't care`_

.. _Don't care: http://www.wtfpl.net/
