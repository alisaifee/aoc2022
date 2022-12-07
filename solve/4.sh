#!/usr/bin/env bash
part1() {
	count=0
	for pairs in $(cat $1); do
		p1=${pairs%,*}
		p2=${pairs/#*,/}

		min_p1="${p1%-*}"
		max_p1="${p1/#*-/}"
		min_p2="${p2%-*}"
		max_p2="${p2/#*-/}"
		if ( (("$min_p1" >= "$min_p2")) && (("$max_p2" >= "$max_p1"))) || ( (("$min_p2" >= "$min_p1")) && (("$max_p1" >= "$max_p2"))); then
			((count += 1))
		fi
	done
	echo $count
}

part2() {
	count=0
	for pairs in $(cat $1); do
		p1=${pairs%,*}
		p2=${pairs/#*,/}
		min_p1="${p1%-*}"
		min_p2="${p2%-*}"
		max_p1="${p1/#*-/}"
		max_p2="${p2/#*-/}"
		if ( (("$min_p1" >= "$min_p2")) && (("$min_p1" <= "$max_p2")) || (("$min_p2" >= "$min_p1")) && (("$min_p2" <= "$max_p1"))); then
			((count += 1))
		fi
	done
	echo $count
}

echo part1: $(part1 $1)
echo part2: $(part2 $1)
