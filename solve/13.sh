#!/usr/bin/env bash
#
compareItems() {
	local -i var_count
	local -n p1=$1
	local -n p2=$2
	local instep=0
	local count=0
	min=$((${#p1[@]} < ${#p2[@]} ? ${#p1[@]} : ${#p2[@]}))
	if ((${#p1[@]} == 0)) && ((${#p2[@]} == 0)); then
		echo 0
		return
	fi
	for idx in $(seq 0 $((min - 1))); do
		((++count))
		l=${p1[$idx]}
		lIsArray=1
		if [[ "$l" =~ ^[0-9]+$ ]]; then
			lIsArray=0
		fi
		if ((1 + idx <= ${#p2[@]})); then
			r=${p2[$idx]}
			rIsArray=1
			if [[ "$r" =~ ^[0-9]+$ ]]; then
				rIsArray=0
			fi
			if [[ $rIsArray = $lIsArray ]]; then
				if ((rIsArray)); then
					instep=$(compareItems $l $r -1)
				else
					instep=$(($l - $r))
				fi
			else
				declare -a temp_$((tcount++))
				declare -n temp=temp_$((tcount++))

				if ((lIsArray == 1)); then
					temp+=($r)
					instep=$(compareItems $l temp -2)
				else
					temp+=($l)
					instep=$(compareItems temp $r -2)
				fi
			fi
			if ((instep != 0)); then
				break
			fi
		fi
	done
	if ((instep == 0)) && ((${#p1[@]} != ${#p2[@]})); then
		if ((${#p1[@]} > ${#p2[@]})); then
			instep=1
		else
			instep=-1
		fi
	fi

	echo $instep
}

compare() {
	v1="$1"
	v2="$2"
	local -a stack
	local curItem
	local -a items
	for item in "$v1" "$v2"; do
		for c in $(echo "$item" | fold -w1); do
			if [[ "$c" = "[" ]]; then
				local -a arr_$((++var_count))
				stack+=(arr_$var_count)
				((++d))
			elif [[ "$c" = "]" ]] || [[ "$c" = "," ]]; then
				local -n v=${stack[-1]}
				if [[ -n $curItem ]]; then
					v+=($curItem)
					curItem=""
				fi
				if [[ "$c" == "]" ]]; then
					if ((${#stack[@]} > 1)); then
						local -n parent=${stack[-2]}
						parent+=(${stack[-1]})
						unset stack[-1]
					fi
				fi
			else
				curItem+=$c
			fi
		done
		items+=(${stack[0]})
		unset stack[0]
	done
	compareItems ${items[0]} ${items[1]}

}
part1() {
	c=1
	local -a packets
	local buf
	while read -r line; do
		if [[ -n "$line" ]]; then
			packets+=("$line")
		fi
	done <$1
	local idx=0
	local sum=0
	for n in $(seq 0 $(((${#packets[@]} / 2) - 1))); do
		pIdx=$((1 + n))
		((idx += 2))
		p1="${packets[$((n * 2))]}"
		p2="${packets[$(((2 * n) + 1))]}"
		comp=$(compare "$p1" "$p2")
		if (($comp <= 0)); then
			((sum += (1 + n)))
		else
			:
		fi
	done
	echo $sum
}
renderPacket() {
	local -n p="$1"
	local buf="["
	local packetSize=${#p[@]}
	local -i itemIdx=0
	for renderable in ${p[@]}; do
		if ((itemIdx > 0)); then
			buf+=","
		fi
		if [[ $renderable =~ ^[0-9]+$ ]]; then
			buf+="$renderable"
		else
			sub="$(renderPacket $renderable)"
			buf+="$sub"
		fi
		((++itemIdx))
	done
	buf+="]"
	echo "$buf"
}
sortPackets() {
	local -a stack
	local curItem
	local -n items="$1"
	local -a parsed
	for item in "${items[@]}"; do
		local value="$item"
		for c in $(echo "$item" | fold -w1); do
			if [[ "$c" = "[" ]]; then
				local -a arr_$((++var_count))
				stack+=(arr_$var_count)
				((++d))
			elif [[ "$c" = "]" ]] || [[ "$c" = "," ]]; then
				local -n v=${stack[-1]}
				if [[ -n $curItem ]]; then
					v+=($curItem)
					curItem=""
				fi
				if [[ "$c" == "]" ]]; then
					if ((${#stack[@]} > 1)); then
						local -n parent=${stack[-2]}
						parent+=(${stack[-1]})
						unset stack[-1]
					fi
				fi
			else
				curItem+=$c
			fi
		done
		parsed+=(${stack[0]})
		unset stack[0]
	done
	local -i counter=0
	size=${#parsed[@]}
	for i in $(seq 0 $((size - 1))); do
		for j in $(seq 0 $((size - i - 2))); do
			local cmp=$(compareItems ${parsed[$j]} ${parsed[$((j + 1))]})
			if ((cmp > 0)); then
				local l="${parsed[$j]}"
				local r="${parsed[$((j + 1))]}"
				parsed[$j]="$r"
				parsed[$((j + 1))]="$l"
			fi
		done
	done
	local -i counter=0
	for value in ${parsed[@]}; do
		local rendered=$(renderPacket $value)
		items[$((counter++))]="$rendered"
	done
}

part2() {
	local -a packets
	local buf
	packets+=("[[6]]")
	packets+=("[[2]]")

	while read -r line; do
		if [[ -n "$line" ]]; then
			packets+=("$line")
		fi
	done <$1

	sortPackets packets
	key=1
	for idx in ${!packets[@]}; do
		packet="${packets[$idx]}"
		if [[ "$packet" = "[[6]]" ]] || [[ "$packet" = "[[2]]" ]]; then
			((key *= (idx + 1)))
		fi
	done
	echo $key
}

echo part 1: "$(part1 $1)"
echo part 2: "$(part2 $1)"
