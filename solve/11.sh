#!/usr/bin/env bash
source $(dirname -- ${BASH_SOURCE[0]})/common.sh
require_bash 4

initializeMonkeys() {
	declare -n inventory="$2"
	declare -n strategy="$3"
	OIFS="$IFS"
	monkey=
	while read line; do
		if [[ "$line" =~ ^Monkey[[:space:]]([[:digit:]]+) ]]; then
			monkey=${BASH_REMATCH[1]}
		elif [[ "$line" =~ Starting[[:space:]]items:*(.*) ]]; then
			IFS=","
			set -- ${BASH_REMATCH[1]}
			inventory[$monkey]=$@
			IFS="$OIFS"
		elif [[ "$line" =~ Operation:[[:space:]]new[[:space:]]=(.*) ]]; then
			strategy["${monkey}_operation"]="${BASH_REMATCH[1]}"
		elif [[ "$line" =~ Test:[[:space:]]divisible[[:space:]]by(.*) ]]; then
			strategy["${monkey}_test"]="${BASH_REMATCH[1]}"
		elif [[ "$line" =~ If[[:space:]]true:.*([[:digit:]]+)$ ]]; then
			strategy["${monkey}_true"]="${BASH_REMATCH[1]}"
		elif [[ "$line" =~ If[[:space:]]false:.*([[:digit:]]+)$ ]]; then
			strategy["${monkey}_false"]="${BASH_REMATCH[1]}"
		fi

	done <$1
}

part1() {
	declare -a monkeyInventory
	declare -A monkeyStrategy
	declare -A monkeyBusiness
	initializeMonkeys $1 monkeyInventory monkeyStrategy
	round=20
	while ((round > 0)); do
		for monkey in ${!monkeyInventory[@]}; do
			for item in ${monkeyInventory[$monkey]}; do
				old=$item
				value=$(((${monkeyStrategy["${monkey}_operation"]})))
				((value /= 3))
				case $(((value % ${monkeyStrategy["${monkey}_test"]}) == 0)) in
				1) next=${monkeyStrategy["${monkey}_true"]} ;;
				0) next=${monkeyStrategy["${monkey}_false"]} ;;
				esac
				((monkeyBusiness[$monkey] += 1))
				monkeyInventory[$next]+=" $value"
			done
			monkeyInventory[$monkey]=""
		done
		((--round))
	done
	for business in ${monkeyBusiness[@]}; do
		echo $business
	done | sort -nr | head -n 2 | paste -sd* | bc
}

part2() {
	declare -a monkeyInventory
	declare -A monkeyStrategy
	declare -A monkeyBusiness
	initializeMonkeys $1 monkeyInventory monkeyStrategy
	round=10000
	divisor=1
	for monkey in ${!monkeyInventory[@]}; do
		((divisor *= ${monkeyStrategy["${monkey}_test"]}))
	done

	while ((round > 0)); do
		for monkey in ${!monkeyInventory[@]}; do
			for item in ${monkeyInventory[$monkey]}; do
				old=$item
				value=$(((${monkeyStrategy["${monkey}_operation"]})))
				value=$(((value % divisor)))
				case $(((value % ${monkeyStrategy["${monkey}_test"]}) == 0)) in
				1) next=${monkeyStrategy["${monkey}_true"]} ;;
				0) next=${monkeyStrategy["${monkey}_false"]} ;;
				esac
				((monkeyBusiness[$monkey] += 1))
				monkeyInventory[$next]+=" $value"
			done
			monkeyInventory[$monkey]=""
		done
		((--round))
	done
	for business in ${monkeyBusiness[@]}; do
		echo $business
	done | sort -nr | head -n 2 | paste -sd* | bc
}

echo part 1: "$(part1 $1)"
echo part 2: "$(part2 $1)"
