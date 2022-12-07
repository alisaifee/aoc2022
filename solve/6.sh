#!/usr/bin/env bash
solve() {
	declare -a buffer
	for char in $(cat $1 | fold -w1); do
		buffer+=($char)
		part=(${buffer[@]: -$2})
		if [[ "${#part[@]}" = $2 ]]; then
			uniq=($(echo ${part[@]} | tr -d ' ' | fold -w1 | sort | uniq))
			if [[ "${#uniq[@]}" = $2 ]]; then
				found=(${buffer[@]/${part[@]}/})
				echo ${#found[@]}
				break
			fi

		fi
	done

}

echo part 1: "$(solve $1 4)"
echo part 2: "$(solve $1 14)"
