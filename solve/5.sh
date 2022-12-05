#!/usr/local/bin/bash
part1() {
	instructions=()
	OIFS="$IFS"
	IFS=
	stacks=0
	while read line; do
		if [[ ! -z $(echo $line | grep -Po '(\[[A-Z]\])') ]]; then
			count=0
			while IFS= read crate; do
				declare -a stack_$((++count))
				if [ "$count" ] >"$stacks"; then
					stacks=$count
				fi

				if [ ! -z $crate ]; then
					declare -n stack=stack_$count
					stack+=($crate)
				fi
			done < <(echo $line | fold -w4 | sed -e 's/\[//g' -e 's/\]//g' -e 's/ //g')
		elif [[ -z "${line%move*}" ]] && [[ ! -z $line ]]; then

			IFS=$OIFS
			move=($(echo $line | grep -Eo '[[:digit:]]+'))
			for c in $(seq ${move[0]}); do
				from=${move[1]}
				to=${move[2]}
				declare -n source=stack_$from
				declare -n dest=stack_$to
				crate="${source[0]}"
				source=(${source[@]:1})
				dest=($crate ${dest[@]})
			done
		fi
	done <$1
	for s in $(seq $stacks); do
		declare -n cur=stack_$s
		echo -n "${cur[0]}"
	done
}

echo part 1: "$(part1 $1)"
