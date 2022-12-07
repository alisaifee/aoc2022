#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

solve() {
	instructions=()
	OIFS="$IFS"
	IFS=
	stacks=0
	while read line; do
		if [[ ! -z $(echo $line | grep -Po '(\[[A-Z]\])') ]]; then
			count=0
			while IFS= read crate; do
				declare -a stack_$((++count))
				if (("$count" > "$stacks")); then
					stacks=$count
				fi

				if [ ! -z $crate ]; then
					declare -n stack=stack_$count
					stack+=($crate)
				fi
			done < <(echo $line | fold -w4 | sed -Ee 's/\[|\]|  //g')
		elif [[ -z "${line%move*}" ]] && [[ ! -z $line ]]; then

			IFS=$OIFS
			move=($(echo $line | grep -Eo '[[:digit:]]+'))
			temp=()
			num=${move[0]}
			from=${move[1]}
			to=${move[2]}
			declare -n dest=stack_$to
			declare -n source=stack_$from
			if [ "$2" = "9000" ]; then
				for c in $(seq $num); do
					crate="${source[0]}"
					source=(${source[@]:1})
					dest=($crate ${dest[@]})
				done
			elif [ "$2" = "9001" ]; then
				for c in $(seq $num); do
					crate="${source[0]}"
					source=(${source[@]:1})
					temp+=($crate)
				done
				dest=(${temp[@]} ${dest[@]})
			fi
		fi
	done <$1
	for s in $(seq $stacks); do
		declare -n cur=stack_$s
		echo -n "${cur[0]}"
	done
}

echo part 1: "$(solve $1 9000)"
echo part 2: "$(solve $1 9001)"
