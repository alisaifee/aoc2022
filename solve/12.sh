#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

declare -A markMapping
h=1
markMapping["S"]=$h
for char in {a..z}; do
	markMapping[$char]=$((++h))
done
markMapping["E"]=$((++h))

buildHeightMap() {
	declare -n m="$2"
	declare -n d="$3"
	i=0
	while read row; do
		((++i))
		j=0
		for column in $(echo $row | fold -w1 | paste -sd' '); do
			((++j))
			m["$i,$j"]=$column
			if [[ "$column" = "S" ]]; then
				d["start"]="$i,$j"
			elif [[ "$column" = "E" ]]; then
				d["end"]="$i,$j"
			fi
		done
	done <$1

}
de=0
getNextMove() {
	local x=$4
	local y=$5

	declare -n m="$4"
	declare -n t="$5"
	local i=$1
	local j=$2
	local depth=$3
	local v=${markMapping[${m["$i,$j"]}]}
	if [[ -n ${t["$i,$j"]} ]] && ((${t["$i,$j"]} <= $depth)); then
		return
	fi
	local lastd=${t["$i,$j"]}
	if [[ -z $lastd ]] || ((depth < lastd)); then
		t["$i,$j"]=$depth
	fi
	local -A directions
	directions["$i,$((j - 1))"]="left"
	directions["$i,$((j + 1))"]="right"
	directions["$((i + 1)),$j"]="down"
	directions["$((i - 1)),$j"]="up"
	local -a next
	for coordinate in ${!directions[@]}; do
		if [[ -n ${m[$coordinate]} ]]; then
			local value=${m[$coordinate]}
			if [[ "$value" != "E" ]]; then
				if ((v - ${markMapping[$value]} <= 1)); then
					if [[ "$value" = "S" ]]; then
						echo $((1 + depth))
						break
					else
						next+=($coordinate)
					fi
				else
					if [[ -n ${d[$coordinate]} ]]; then
						((d[$coordinate] += 1))
					else
						d[$coordinate]=1
					fi

				fi
			fi
		else
			:
		fi
	done
	for coordinate in ${next[@]}; do
		local ii=${coordinate%,*}
		local jj=${coordinate/#*,/}
		getNextMove $ii $jj $((depth + 1)) $x $y
	done

}
part1() {
	declare -A heightMap
	declare -A directions
	declare -A travelled
	buildHeightMap $1 heightMap directions
	start=${directions["start"]}
	end=${directions["end"]}
	i=${end%,*}
	j=${end/#*,/}
	getNextMove $i $j 0 heightMap travelled | sort | uniq | sort -n | head -n1
}

echo part 1: "$(part1 $1)"
