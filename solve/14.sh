#!/usr/bin/env bash
#
buildGrid(){
	local -n gridScan=$2
	local -n gridInfo=$3
	local -a rocks
	OIFS="$IFS"
	while read line; do
		IFS=" -> "
		set -- $line
		local x1=""
		local y1=""
		for coordinate in $@; do
			local x2="${coordinate%,*}"
			local y2="${coordinate/#*,/}"
			local xmin=0 xmax=0 ymin=0 ymax=0
			if [[ -n $x1 ]]; then
				xmin=$((x2 < x1 ? x2 : x1))
				xmax=$((x2 > x1 ? x2 : x1))
				ymin=$((y2 < y1 ? y2 : y1))
				ymax=$((y2 > y1 ? y2 : y1))
				IFS="$OIFS"
				for _y in $(seq $ymin $ymax); do
					for _x in $(seq $xmin $xmax); do
						gridScan["$_x,$_y"]="#"
					done
				done
			fi
			x1=$x2
			y1=$y2
		done
		IFS="$OIFS"
		unset x1
		unset y1
	done < $1
	IFS="$OIFS"
	gridScan["500,0"]="+"
	local minx maxy minx maxx
	for coordinate in ${!gridScan[@]}; do
		x=${coordinate%,*}
		y=${coordinate/#*,/}
		if [[ -z $minx ]] || (( x < minx)); then
			minx=$x
		fi
		if [[ -z $maxx ]] || (( x > maxx)); then
			maxx=$x
		fi
		if [[ -z $miny ]] || (( y < miny)); then
			miny=$y
		fi
		if [[ -z $maxy ]] || (( y > maxy)); then
			maxy=$y
		fi
	done
	#for _x in $(seq $minx $maxx); do
	#	for _y in $(seq $miny $maxy); do
	#		if [[ -z ${gridScan["$_x,$_y"]} ]]; then
	#			gridScan["$_x,$_y"]="."
	#		fi
	#	done
	#done
	gridInfo["min"]="$minx,$miny"
	gridInfo["max"]="$maxx,$maxy"

}
renderGrid(){
	local -n renderedGrid=$1
	local -n i=$2
	local minx miny maxx maxy
	minx=${i["min"]%,*}
	miny=${i["min"]/#*,/}
	maxx=${i["max"]%,*}
	maxy=${i["max"]/#*,/}
	for _y in $(seq $miny $maxy); do
		for _x in $(seq $minx $maxx); do
			if [[ -z "${renderedGrid["$_x,$_y"]}" ]]; then
				>&2 echo -n "."
			else
				>&2 echo -n "${renderedGrid["$_x,$_y"]}"
			fi
		done
		>&2 echo
	done


}
dropSand(){
	local -n opGrid=$1
	local -n i=$2
	local minx=$3
	local miny=$4
	local maxx=$5
	local maxy=$6
	local count=$7
	local curx=500
	local cury=1
	local lastx lasty
	local last=

	while [[ 1 ]]; do
		if (( cury >= maxy )); then
			unset opGrid["$lastx,$lasty"]
			unset lastx
			unset lasty
			break
		fi
		if [[ -z ${opGrid["$curx,$cury"]} ]] && [[ -z $lastx ]]; then
			opGrid["$curx,$cury"]="O"
			lastx=$curx
			lasty=$cury
		elif [[ -z ${g["$curx,$cury"]} ]] && [[ -n $lastx ]] && (( lasty+1 == cury )); then
			unset opGrid["$lastx,$lasty"]
			opGrid["$curx,$cury"]="O"
			lastx=$curx
			lasty=$cury
		fi
		if [[ -z ${opGrid["$curx,$((1+cury))"]} ]]; then
			:
		elif [[ -n ${opGrid["$curx,$cury"]} ]]; then
			if [[ -z ${opGrid["$((curx-1)),$((cury+1))"]} ]]; then
				((--curx))
				if (( curx < minx )); then
					unset lastx
					unset lasty
					break
				fi
			elif [[ -z ${opGrid["$((curx+1)),$((cury+1))"]} ]]; then
				((++curx))
				if (( curx > maxx )); then
					unset lastx
					unset lasty
					break
				fi
			else
				break
			fi
		fi
		((++cury))
	done
	if [[ -n $lastx ]]; then
		info["drop"]="$lastx,$lasty"
	else
		unset info["drop"]
	fi
}
part1(){
	local -A grid
	local -A info
	local minx maxy minx maxx
	buildGrid $1 grid info
	minx=${info["min"]%,*}
		miny=${info["min"]/#*,/}
	maxx=${info["max"]%,*}
	maxy=${info["max"]/#*,/}
	c=0
	while [[ 1 ]]; do
		dropSand grid info $minx $miny $maxx $maxy $c
		if [[ -z ${info["drop"]} ]]; then
			break
		fi
		((++c))
	done
	renderGrid grid info
	echo $c
}


echo part 1: "$(part1 $1)"
