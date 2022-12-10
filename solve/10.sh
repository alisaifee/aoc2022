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
	echo
	cat $1 |
		sed -e 's/noop/0/' -Ee 's/addx (.)/0\n\1/' |
		sed -Ee 's/^([[:digit:]]+)/p\n\1+/' -Ee 's/^-([[:digit:]]+)/p\n\1-/' |
		dc -e1 -f - |
		nl -v0 -w2 -s' ' |
		sed -E -e 's/([[:digit:]]+) (-*[[:digit:]]+)/((\1%40-(\2))^2 <= 1)/' |
		bc |
		tr '0' '.' | tr '1' '#' |
		paste -sd'\0' |
		fold -w40

}
echo part 1: $(part1 $1)
echo part 2: "$(part2 $1)"
