#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

generateMap() {
	declare -n _map="$2"
	declare -n _range="$3"
	j=0
	while read line; do
		((++i))
		for height in $(echo $line | fold -w1); do
			((++j))
			_map[$i, $j]=$height
		done
		_range[1]=$j
		j=0
	done <$1
	_range[0]=$i
}

part1() {
	declare -A map
	i=0
	j=0
	declare -A maxleft
	declare -A maxabove
	declare -A maxleftall
	declare -A maxaboveall
	while read line; do
		((++i))
		for height in $(echo $line | fold -w1); do
			((++j))
			maxleft[$i, $j]=${maxleftall[$i]}
			if [[ -z ${maxleftall[$i]} ]] || ((maxleftall[$i] < $height)); then
				maxleftall[$i]=$height
			fi
			maxabove[$i, $j]=${maxaboveall[$j]}
			if [[ -z ${maxaboveall[$j]} ]] || ((maxaboveall[$j] < $height)); then
				maxaboveall[$j]=$height
			fi
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
			if [[ -z ${maxleft[$i, $j]} ]] || [[ -z ${maxabove[$i, $j]} ]]; then
				visible=$(((visible + 1)))
			else
				if (($height <= ${maxleft[$i, $j]})) && (($height <= ${maxabove[$i, $j]})); then
					_i=$i
					_j=$j
					righthidden=0
					bottomhidden=0
					while (($_i < $imax)); do
						((++_i))
						if ((${map[$_i, $j]} >= $height)); then
							righthidden=1
							break
						fi
					done
					while (($_j < $jmax)); do
						((++_j))
						if ((${map[$i, $_j]} >= $height)); then
							bottomhidden=1
							break
						fi
					done
					if (($righthidden == 0)) || (($bottomhidden == 0)); then
						((visible++))
					fi
				else
					((visible++))
				fi
			fi
		done
		j=0
	done
	echo $visible
}
part2() {
	declare -A map
	declare -a range
	generateMap $1 map range
	imax=${range[0]}
	jmax=${range[1]}
	i=0
	j=0
	maxscore=0
	while (($i < $imax)); do
		((++i))
		while (($j < $jmax)); do
			((++j))
			height=${map[$i, $j]}
			if (($height == 0)); then
				continue
			fi

			_j=$j
			score_left=0
			score_right=0
			score_above=0
			belows=0
			while (($_j > 1)); do
				((--_j))
				((++score_left))
				if (($height <= ${map[$i, $_j]})); then
					break
				fi
			done

			_j=$j
			while (($_j < $jmax)); do
				((++_j))
				((++score_right))
				if (($height <= ${map[$i, $_j]})); then
					break
				fi
			done
			_i=$i
			while (($_i > 1)); do
				((--_i))
				((++score_above))
				if (($height <= ${map[$_i, $j]})); then
					break
				fi
			done

			_i=$i
			while (($_i < $imax)); do
				((++_i))
				((++belows))
				if (($height <= ${map[$_i, $j]})); then
					break
				fi
			done
			score=$((($score_above * $belows * $score_left * $score_right)))
			if (($score >= $maxscore)); then
				maxscore=$score
			fi

		done
		j=0
	done
	echo $maxscore
}

echo part 1: $(part1 $1)
echo part 2: $(part2 $1)
