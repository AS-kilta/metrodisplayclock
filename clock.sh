#!/bin/bash

# these are P1-08 and P1-10 on RasPi rev2, respectively
gpio_even=14 # turn to even minute
gpio_odd=15 # turn to odd minute
dir=/sys/class/gpio
user=pi
timetxt=$(dirname $(readlink -nf $0))/time.txt

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

save () {
	echo `date +%s` > $timetxt
}

load () {
	[ ! -e $timetxt ] && return
	read orig < $timetxt
	curr=`date +%s`
	diffm=$(((curr-orig)/60))
	h=$((diffm/60%12))
	m=$((diffm%60))
	spin=$((h*60+m))
	echo "Clock diff $h:$m, difference $spin minutes (plus adjust time)"
	pair=$((orig/60%2))
	while [ "$spin" -gt 0 ]; do
		[ $pair -eq 0 ] && odd || even
		pair=$((1-pair))
		curr=`date +%s`
		orig=$((orig+60))
		spin=$((((curr-orig)/60)%(12*60)))
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
		save
		date
		t=`date +%M`
		waitmin $t
		odd
		save
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
	save)
		save
		;;
	load)
		load
		;;
	*)
		echo usage: $0 register/even/odd/both/fast/realtime/save/load
		;;
esac
