#!/usr/bin/env bash

part1() {
	OIFS="$IFS"
	declare -a values=(1)
	while read -r instruction; do
		set -- $instruction
		cmd=$1
		arg=$2
		cur=${values[-1]}
		if [[ "$cmd" = "noop" ]]; then
			values+=(${values[-1]})
		else
			values+=(${values[-1]})
			values+=($(((${values[-1]} + arg))))
		fi

	done <$1
	sum=0
	for cycle in 20 60 100 140 180 220; do
		((sum += cycle * ${values[cycle - 1]}))
	done
	echo $sum

}

part2() {
	OIFS="$IFS"
	declare -a values=(1)
	while read -r instruction; do
		set -- $instruction
		cmd=$1
		arg=$2
		cur=${values[-1]}
		if [[ "$cmd" = "noop" ]]; then
			values+=(${values[-1]})
		else
			values+=(${values[-1]})
			values+=($(((${values[-1]} + arg))))
		fi

	done <$1
	sum=0
	for cycle in "1,40" "41,80" "81,120" "121,160" "161,200" "201,240"; do
		IFS=,
		set -- $cycle
		range=$(eval echo "{$1..$2}")
		IFS="$OIFS"
		for c in $range; do
			pos=${values[$((c - 1))]}
			active=$((pos - ((c - $1))))
			active=$((${active#-} <= 1))
			if [[ $active = 1 ]]; then
				echo >&2 -n '#'
			else
				echo >&2 -n '.'
			fi
		done
		echo >&2
	done

}

echo part 1: $(part1 $1)
echo part 2: $(part2 $1)
