#!/bin/bash

# these are P1-08 and P1-10 on RasPi rev2, respectively
gpio_even=14 # turn to even minute
gpio_odd=15 # turn to odd minute
dir=/sys/class/gpio
user=pi

register () {
	echo $gpio_even > $dir/export
	echo $gpio_odd > $dir/export
	echo low > $dir/gpio$gpio_even/direction
	echo low > $dir/gpio$gpio_odd/direction
	chown $user $dir/gpio$gpio_even/value $dir/gpio$gpio_odd/value
}

toggle () {
	echo 1 > $dir/gpio$1/value
	sleep 0.45
	echo 0 > $dir/gpio$1/value
	sleep 0.05
}

even () {
	toggle $gpio_even
}

odd () {
	toggle $gpio_odd
}

fastloop () {
	while true; do
		even
		odd
	done
}

ctrl_c () {
	echo 0 > $dir/gpio$gpio_even/value
	echo 0 > $dir/gpio$gpio_odd/value
	exit $?
}

waitmin () {
	# because "sleep 60" would drift anyway and this also supports short ^Z's
	t=`date +%M`
	while [ $t -eq $1 ]; do
		t=`date +%M`
		sleep 1
	done
}
rtloop () {
	if [ ! -w $dir/gpio$gpio_even/value ]; then
		echo Permission denied on gpios
		exit 1
	fi

	while true; do
		t=`date +%M`
		waitmin $t
		even
		date
		t=`date +%M`
		waitmin $t
		odd
		date
	done
}

trap ctrl_c SIGINT

case "$1" in
	register)
		register
		;;
	even)
		even
		;;
	odd)
		odd
		;;
	both)
		even
		odd
		;;
	fast)
		fastloop
		;;
	realtime)
		rtloop
		;;
	*)
		echo usage: $0 register/even/odd/both/fast/realtime
		;;
esac
