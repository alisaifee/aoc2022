#!/usr/local/bin/bash

input=$(cat $1)
declare -A mapping
i=0
for char in $(echo {a..z} {A..Z}); do
	mapping[$char]=$((++i))
done

part1() {
	for contents in $input; do
		midpoint=$(echo ${#contents} / 2 | bc)
		s1=${contents:0:$midpoint}
		s2=${contents:$midpoint:$midpoint}
		common=$(comm -12 <(echo $s1 | fold -w1 | sort) <(echo $s2 | fold -w1 | sort) | sort | uniq)
		for char in $common; do
			echo ${mapping[$char]}
		done
	done | paste -sd+ | bc
}

part2() {
	groupCounter=0
	declare -A groupContents
	for contents in $input; do
		groupContents[$groupCounter]=$contents
		groupCounter=$((++groupCounter))
		if [ "$groupCounter" = 3 ]; then
			common=$(comm -12 <(echo ${groupContents[0]} | fold -w1 | sort) <(echo ${groupContents[1]} | fold -w1 | sort) | sort | uniq | tr -d '\n')
			common=$(comm -12 <(echo $common | fold -w1 | sort) <(echo ${groupContents[2]} | fold -w1 | sort) | sort | uniq)
			for char in $common; do
				echo ${mapping[$char]}
			done
			groupCounter=0
		fi
	done | paste -sd+ | bc
}

echo part1: $(part1)
echo part2: $(part2)
