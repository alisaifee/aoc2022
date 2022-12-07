#!/usr/local/bin/bash
part1() {
	declare -a dirstack
	declare -A sizes
	mode=command
	while read line; do
		if [[ "$line" =~ ^\$[[:space:]](cd|ls)([[:space:]](.*))* ]]; then
			mode="cmd"
			cmd=${BASH_REMATCH[1]}
			arg=${BASH_REMATCH[3]}
			if [[ "$cmd" = "cd" ]]; then
				if [[ $arg = ".." ]]; then
					child=${dirstack[-1]}
					unset dirstack[-1]
					((sizes[${dirstack[-1]}] += ${sizes[$child]}))
				else
					if ((${#dirstack[@]} > 1)); then
						dirstack+=("${dirstack[-1]}/$arg")
					else
						dirstack+=($arg)
					fi
				fi
			elif [[ "$cmd" = "ls" ]]; then
				mode="list"
			fi
		else
			if [[ ! "$line" =~ ^dir.* ]]; then
				size=${line% *}
				cur=${dirstack[-1]}
				((sizes[$cur] += $size))
			fi
		fi
	done <$1
	total=0
	for dir in "${!sizes[@]}"; do
		size=${sizes[$dir]}
		if (("$size" < "100000")); then
			((total += $size))
		fi
	done
	echo $total
}

part2() {
	max=$2
	required=$3
	declare -a dirstack
	declare -A sizes
	mode=command
	while read line; do
		if [[ "$line" =~ ^\$[[:space:]](cd|ls)([[:space:]](.*))* ]]; then
			mode="cmd"
			cmd=${BASH_REMATCH[1]}
			arg=${BASH_REMATCH[3]}
			if [[ "$cmd" = "cd" ]]; then
				if [[ $arg = ".." ]]; then
					child=${dirstack[-1]}
					unset dirstack[-1]
					((sizes[${dirstack[-1]}] += ${sizes[$child]}))
				else
					if ((${#dirstack[@]} > 1)); then
						dirstack+=("${dirstack[-1]}/$arg")
					else
						dirstack+=($arg)
					fi
				fi
			elif [[ "$cmd" = "ls" ]]; then
				mode="list"
			fi
		else
			if [[ ! "$line" =~ ^dir.* ]]; then
				size=${line% *}
				cur=${dirstack[-1]}
				((sizes[$cur] += $size))
			fi
		fi
	done <$1
	while (( ${#dirstack[@]} > 1 )); do
		child=${dirstack[-1]}
		unset dirstack[-1]
		(( sizes[${dirstack[-1]}]+=${sizes[$child]} ))
	done

	left=$((($max-${sizes[/]})))
	reclaim=$((($required-$left)))
	candidate=""
	for dir in ${!sizes[@]}; do
		if (( ${sizes[$dir]} >= $reclaim )); then
			if [[ -z $candidate ]] || (( ${sizes[$dir]} < ${sizes[$candidate]} )); then
				candidate=$dir
			fi
		fi
	done
	echo ${sizes[$candidate]}
}

echo part 1: "$(part1 $1)"
echo part 2: "$(part2 $1 70000000 30000000)"
