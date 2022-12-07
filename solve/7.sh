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

echo part 1: "$(part1 $1)"
