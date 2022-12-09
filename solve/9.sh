#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

parseHeadMotions() {
	declare -n motions="$2"
	motions[0]="0,0"
	while read -r motion; do
		direction=${motion:0:1}
		steps=${motion:1}
		c=0
		while ((c < $steps)); do
			lasthi=${motions[-1]%,*}
			lasthj=${motions[-1]/#*,/}
			((++c))
			case $direction in
			U) motions+=("$(((++lasthi))),$lasthj") ;;
			D) motions+=("$(((--lasthi))),$lasthj") ;;
			L) motions+=("$lasthi,$(((--lasthj)))") ;;
			R) motions+=("$lasthi,$(((++lasthj)))") ;;
			esac
		done
	done <$1
}
part1() {
	declare -a hpos
	parseHeadMotions $1 hpos
	ti=0
	tj=0
	nt=
	declare -a tpos=("0,0")
	OIFS="$IFS"
	for move in ${!hpos[@]}; do
		IFS=","
		set -- ${hpos[$move]}
		i=$1
		j=$2
		jdist=$((($j - $tj)))
		idist=$((($i - $ti)))
		if [[ $jdist != 0 ]] && [[ $idist = 0 ]]; then
			case $(((jdist > 0))) in
			1) direction=R ;;
			0) direction=L ;;
			esac
		elif [[ $idist != 0 ]] && [[ $jdist = 0 ]]; then
			case $(((idist > 0))) in
			1) direction=U ;;
			0) direction=D ;;
			esac
		else
			if ((idist > 0)) && ((jdist > 0)); then
				direction="UR"
			elif ((idist > 0)) && ((jdist < 0)); then
				direction="UL"
			elif ((idist < 0)) && ((jdist > 0)); then
				direction="DR"
			elif ((idist < 0)) && ((jdist < 0)); then
				direction="DL"
			fi
		fi
		idistabs=${idist#-}
		jdistabs=${jdist#-}
		if ((idistabs == 0)) && ((jdistabs <= 1)); then
			:
		elif ((jdistabs == 0)) && ((idistabs <= 1)); then
			:
		else
			if [[ (($idistabs == 0)) && (($jdistabs == 2)) ]] || [[ (($jdistabs == 0)) && (($idistabs == 2)) ]]; then
				case $direction in
				L) ((--tj)) ;;
				R) ((++tj)) ;;
				U) ((++ti)) ;;
				D) ((--ti)) ;;
				esac
				echo >&2 $i $j $ti $tj $direction
			else
				if ((jdist + idist == 0)) || ((jdist + idist == 2)) || ((jdist + idist == -2)); then
					:
				else
					case $direction in
					UR)
						((++ti))
						((++tj))
						;;
					UL)
						((++ti))
						((--tj))
						;;
					DR)
						((--ti))
						((++tj))
						;;
					DL)
						((--ti))
						((--tj))
						;;
					esac
				fi
				echo >&2 $i $j $ti $tj $direction
			fi
		fi
		tpos+=("$ti,$tj")
	done
	IFS="$OIFS"
	for pos in ${tpos[@]}; do
		echo $pos
	done | sort | uniq | wc -l
}

part2() {
	declare -a hpos
	declare -a knots
	parseHeadMotions $1 hpos
	for knot in {0..9}; do
		knots[$knot]="0,0"
		declare -a tpos_$knot
		declare -n arr="tpos_$knot"
		arr+=("0,0")
	done
	OIFS="$IFS"
	for move in ${!hpos[@]}; do
		IFS=","
		for knot in {1..9}; do
			declare -n arr="tpos_$knot"
			if (($knot == 1)); then
				set -- ${hpos[$move]}
				i=$1
				j=$2
				set -- ${knots[1]}
				ti=$1
				tj=$2
			else
				set -- ${knots[$(((knot - 1)))]}
				i=$1
				j=$2
				set -- ${knots[$(((knot)))]}
				ti=$1
				tj=$2
			fi
			jdist=$((($j - $tj)))
			idist=$((($i - $ti)))
			if [[ $jdist != 0 ]] && [[ $idist = 0 ]]; then
				case $(((jdist > 0))) in
				1) direction=R ;;
				0) direction=L ;;
				esac
			elif [[ $idist != 0 ]] && [[ $jdist = 0 ]]; then
				case $(((idist > 0))) in
				1) direction=U ;;
				0) direction=D ;;
				esac
			else
				if ((idist > 0)) && ((jdist > 0)); then
					direction="UR"
				elif ((idist > 0)) && ((jdist < 0)); then
					direction="UL"
				elif ((idist < 0)) && ((jdist > 0)); then
					direction="DR"
				elif ((idist < 0)) && ((jdist < 0)); then
					direction="DL"
				fi
			fi
			idistabs=${idist#-}
			jdistabs=${jdist#-}
			if ((idistabs == 0)) && ((jdistabs <= 1)); then
				:
			elif ((jdistabs == 0)) && ((idistabs <= 1)); then
				:
			else
				if [[ (($idistabs == 0)) && (($jdistabs == 2)) ]] || [[ (($jdistabs == 0)) && (($idistabs == 2)) ]]; then
					case $direction in
					L) ((--tj)) ;;
					R) ((++tj)) ;;
					U) ((++ti)) ;;
					D) ((--ti)) ;;
					esac
					echo >&2 move knot $knot: $i $j $ti $tj $direction
				else
					if ((jdist + idist == 0)) || ((jdist + idist == 2)) || ((jdist + idist == -2)); then
						:
					else
						case $direction in
						UR)
							((++ti))
							((++tj))
							;;
						UL)
							((++ti))
							((--tj))
							;;
						DR)
							((--ti))
							((++tj))
							;;
						DL)
							((--ti))
							((--tj))
							;;
						esac
					fi
					echo >&2 move knot $knot: $i $j $ti $tj $direction
				fi
				knots[$knot]="$ti,$tj"
				arr+=("$ti,$tj")
			fi
		done
	done
	IFS="$OIFS"
	for pos in ${tpos_9[@]}; do
		echo $pos
	done | sort | uniq | wc -l
}

echo part 1: $(part1 $1)
echo part 2: $(part2 $1)
