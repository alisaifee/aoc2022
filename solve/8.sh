#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

part1() {
	declare -A map
	i=0
	j=0
	declare -A maxleft
	declare -A maxtop
	declare -A maxright
	declare -A maxbottom
	declare -A maxleftall
	declare -A maxtopall
	while read line; do
		((++i))
		for height in $(echo $line | fold -w1); do
			((++j))
			maxleft[$i, $j]=${maxleftall[$i]}
			if [[ -z ${maxleftall[$i]} ]] || ((maxleftall[$i] < $height)); then
				maxleftall[$i]=$height
			fi
			maxtop[$i, $j]=${maxtopall[$j]}
			if [[ -z ${maxtopall[$j]} ]] || ((maxtopall[$j] < $height)); then
				maxtopall[$j]=$height
			fi
			jr=$j
			ib=$i
			while (($jr > 0)); do
				if [[ ! -z ${map[$i, $(((jr - 1)))]} ]] && (($height >= ${map[$i, $(((jr - 1)))]})); then
					maxright[$i, $(((jr - 1)))]=$height
				fi
				((--jr))
			done
			while (($ib > 0)); do
				if [[ ! -z ${map[$(((ib - 1))), $j]} ]] && (($height >= ${map[$(((ib - 1))), $j]})); then
					maxbottom[$(((ib - 1))), $j]=$height
				fi
				((--ib))
			done
			map[$i, $j]=$height
		done
		jmax=$j
		j=0
	done <$1
	imax=$i

	visible=0
	i=0
	j=0
	while (($i < $imax)); do
		((++i))
		while (($j < $jmax)); do
			((++j))
			height=${map[$i, $j]}
			if [[ -z ${maxleft[$i, $j]} ]] || [[ -z ${maxtop[$i, $j]} ]] || [[ -z ${maxbottom[$i, $j]} ]] || [[ -z ${maxright[$i, $j]} ]]; then
				visible=$(((visible + 1)))
			else
				if (($height <= ${maxleft[$i, $j]})) && (($height <= ${maxtop[$i, $j]})) && (($height <= ${maxright[$i, $j]})) && (($height <= ${maxbottom[$i, $j]})); then
					continue
				else
					((visible++))
				fi
			fi
		done
		j=0
	done
	echo $visible
}

echo part 1: $(part1 $1)
