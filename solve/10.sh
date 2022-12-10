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
		((sum+=cycle*${values[cycle-1]}))
	done
	echo $sum

}

echo part 1: $(part1 $1)
